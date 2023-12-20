# LRC_Projet
Auteurs : Sarah ENG, Lin ZHENGQING

Projet de LRC : Ecriture en Prolog d’un démonstrateur basé sur l’algorithme des tableaux pour la logique de description ALC

## Partie 1 : Etape préliminaire de vérification et de mise en forme de la Tbox et de la Abox
Lorsque nous obtenons une base de connaissances, nous la traitons pour que TBox et ABox ne contiennent que des concepts atomiques. On définit les predicats suivants pour effectuer cette tache :
### `concept`
Le prédicat `concept` permet de vérifier la correction syntaxique de toutes les expressions d'entrée (Tbox, Abox et entrée de l'utilisateur).

Pour implémenter ce prédicat, nous nous sommes basées sur la définition récursive du concept, décrite dans la section _"Quelques rappels préliminaires/I. Logique de description ALC/3. Grammaire"_, qui dit qu'un concept est :
- soit un concept atomique (ou `top` ou `bottom`, qui sont définis comme concept atomique dans ce projet)
- soit une expression `not(concept)`
- soit une expression `and(concept, concept)`
- soit une expression `or(concept, concept)`
- soit une expression `some(role, concept)`
- ou soit une expression `all(role, concept)`.

Il prend donc en paramètre une expression, et renvoie true s'il s'agit bien d'un concept.
> concept(E):
> - E : expression dont on veut savoir s'il s'agit bien d'un concept

#### Tests réalisés et les explications :
```prolog
?- concept(X).
X = personne.
% Parce qu'on a mis un cut '!' en fin de la première clause :
% concept(X) :- cnamea(X),!.
?- concept(livre).
true.
?- concept(aCree).
false.
?- concept(qqch).
false.
```

### `pas-autoref`
Le prédicat `pas-autoref` permet de vérifier si un concept n'est pas auto-référent. Ce prédicat sera notamment utilisé plus tard pour le traitement de la Tbox, qui vont vérifier pour touts leurs axiomes, s'ils sont auto-référents.

Pour une définition de concept de la Tbox de la forme C ≡ E :
- récursivement, on applique la définition E du concept C
  * soit E est un concept atomique, d'après la définition, on sait que C est un concept non atomique, donc ils sont forcément différents, donc il n'y a pas d'autoréférence
  * soit E est un concept non atomique, il faut vérifier qu'il ne s'agit pas de C, et s'ils sont bien différents, on continue la récursion de `pas-autoref` sur la définition du concept non atomique E
  * soit E commence par un opérateur et on applique récursivement `pas-autoref` sur les concepts de cette opération (deux appels récursifs sur chacun des membres s'il s'agit d'un opérateur `and` ou `or`, un seul appel récursif sur le deuxième membre s'il s'agit d'un opérateur `some` ou `all`).

Il prend en paramètre un concept et son expression conceptuelle équivalente dans la Tbox, et renvoie true s'il n'est pas auto-référent.
> pas-autoref(C, E):
> - C : concept
> - E : expression équivalente du concept C

#### Tests réalisés et les explications :
- tests de toutes les définitions dans `equiv` du fichier ta.pl
- on modifie ta.pl en définissant `sculpture` comme un concept non atomique et en ajoutant sa définition dans `equiv` (cf exemple de Tbox circulaire de l'énoncé) et aussi un nom de rôle `creePar`(seulement pour vérifier le fonctionnement du prédicat `autoref`).

L'explication d'un processus d'exécution :
```prolog
[trace]  ?- autoref(sculpteur,and(personne,some(aCree,sculpture))).
   Call: (10) autoref(sculpteur, and(personne, some(aCree, sculpture))) ? creep
^  Call: (11) not(pas-autoref(sculpteur, and(personne, some(aCree, sculpture)))) ? creep
   Call: (12) pas-autoref(sculpteur, and(personne, some(aCree, sculpture))) ? creep

% Au début, Prolog essaie d'utiliser les premières deux règles du pas-autoref => fail :

   Call: (13) cnamea(and(personne, some(aCree, sculpture))) ? creep
   Fail: (13) cnamea(and(personne, some(aCree, sculpture))) ? creep

   Redo: (12) pas-autoref(sculpteur, and(personne, some(aCree, sculpture))) ? creep
   Call: (13) cnamena(and(personne, some(aCree, sculpture))) ? creep
   Fail: (13) cnamena(and(personne, some(aCree, sculpture))) ? creep

% Puis il ne peut que utiliser la règle "and". Il vérifie ensuite les littéraux négatifs de cette règle un par un :

   Redo: (12) pas-autoref(sculpteur, and(personne, some(aCree, sculpture))) ? creep
   Call: (13) concept(personne) ? creep
   Call: (14) cnamea(personne) ? creep
   Exit: (14) cnamea(personne) ? creep
   Exit: (13) concept(personne) ? creep
   Call: (13) concept(some(aCree, sculpture)) ? creep
   Call: (14) cnamea(some(aCree, sculpture)) ? creep
   Fail: (14) cnamea(some(aCree, sculpture)) ? creep
   Redo: (13) concept(some(aCree, sculpture)) ? creep
   Call: (14) cnamena(some(aCree, sculpture)) ? creep
   Fail: (14) cnamena(some(aCree, sculpture)) ? creep
   Redo: (13) concept(some(aCree, sculpture)) ? creep
   Call: (14) rname(aCree) ? creep
   Exit: (14) rname(aCree) ? creep
   Call: (14) concept(sculpture) ? creep
   Call: (15) cnamea(sculpture) ? creep
   Exit: (15) cnamea(sculpture) ? creep
   Exit: (14) concept(sculpture) ? creep
   Exit: (13) concept(some(aCree, sculpture)) ? creep

   Call: (13) pas-autoref(sculpteur, personne) ? creep
   Call: (14) cnamea(personne) ? creep
   Exit: (14) cnamea(personne) ? creep
   Call: (14) sculpteur\=personne ? creep
   Exit: (14) sculpteur\=personne ? creep
   Exit: (13) pas-autoref(sculpteur, personne) ? creep

   Call: (13) pas-autoref(sculpteur, some(aCree, sculpture)) ? creep
   Call: (14) cnamea(some(aCree, sculpture)) ? creep
   Fail: (14) cnamea(some(aCree, sculpture)) ? creep
   Redo: (13) pas-autoref(sculpteur, some(aCree, sculpture)) ? creep
   Call: (14) cnamena(some(aCree, sculpture)) ? creep
   Fail: (14) cnamena(some(aCree, sculpture)) ? creep
   Redo: (13) pas-autoref(sculpteur, some(aCree, sculpture)) ? creep
   Call: (14) rname(aCree) ? creep
   Exit: (14) rname(aCree) ? creep
   Call: (14) concept(sculpture) ? creep
   Call: (15) cnamea(sculpture) ? creep
   Exit: (15) cnamea(sculpture) ? creep
   Exit: (14) concept(sculpture) ? creep
   Call: (14) pas-autoref(sculpteur, sculpture) ? creep
   Call: (15) cnamea(sculpture) ? creep
   Exit: (15) cnamea(sculpture) ? creep
   Call: (15) sculpteur\=sculpture ? creep
   Exit: (15) sculpteur\=sculpture ? creep
   Exit: (14) pas-autoref(sculpteur, sculpture) ? creep
   Exit: (13) pas-autoref(sculpteur, some(aCree, sculpture)) ? creep

   Exit: (12) pas-autoref(sculpteur, and(personne, some(aCree, sculpture))) ? creep

^  Fail: (11) not(user:pas-autoref(sculpteur, and(personne, some(aCree, sculpture)))) ? creep

   Fail: (10) autoref(sculpteur, and(personne, some(aCree, sculpture))) ? creep
false.
```
Les autres requêtes :
```prolog
?- autoref(sculpture, and(objet, all(creePar,sculpteur))).
true.

?- autoref(auteur,and(personne,some(aEcrit,livre))).
false.

?- autoref(editeur, and(personne,and(not(some(aEcrit,livre)),some(aEdite,livre)))).
false.

?- autoref(parent, and(personne,some(aEnfant,anything))).
false.

?- autoref(sculpteur,and(personne,some(aCree,sculpture))).
false.
```

### `autoref`
Le prédicat `pas-autoref` permet de vérifier si un concept n'est pas auto-référent. 

Il s'agit de la négation du prédicat `pas-autoref`.
Il prend en paramètre un concept et son expression conceptuelle équivalente dans la Tbox, et renvoie true s'il est auto-référent.

> autoref(C, E):
> - C : concept
> - E : expression équivalente du concept C

#### Partie de tests
Pareil que `pas-autoref`, on vérifie juste qu'il s'agit bien de la négation.

### `applique_def`
Le prédicat `applique_def` applique la définition d'un concept et d'autres définitions de la Tbox, jusqu'à ce qu'il n'y ait plus que des concepts atomiques.

Il applique de manière récursive la définition du concept. De même, si l'expression du concept comporte des opérateurs, il applique `applique_def` de manière récursive sur tous les membres des opérateurs qui sont des concepts. De plus, on appelle `concept` pour toujours vérifier la correction syntaxique des expressions.

Il prend en paramètre un concept et un résultat.
> applique_def(concept, res) :
> - concept : concept dont on veut trouver l'expression équivalente avec uniquement des concepts atomiques
> - res : expression équivalente de concept qu'on a trouvé

#### Partie de tests
Ce prédicat est utilisé par le prédicat suivant `applique_def_Tbox`, il suffit donc de vérifier la fonctionnalité de ce dernier.

### `applique_def_Tbox`
Le prédicat `applique_def_Tbox` applique `applique_def` sur tous les concepts de la Tbox.

On récupère les expressions de tous les concepts de la Tbox, et pour chacune, on récupère l'expression équivalente avec uniquement des concepts atomiques en appelant `applique_def`. On vérifie également pour chaque concept de la Tbox qu'il n'est pas auto-référent en appelant `pas-autoref`. Pour parcourir et appliquer ce traitement sur la liste, on effectue le traitement sur le premier élément de la liste, puis on fait l'appel récursif sur le reste de la liste, en mettant à jour les listes de résultats.

Il prend en paramètres la liste des concepts de la Tbox, une liste partielle de résultats et une liste finale de résultats.
> applique_def_Tbox(L, ResPartiel, ResFinal) :
> - L : liste des concepts (non atomiques) de la Tbox
> - ResPartiel : liste des résultats à cet instant/appel récursif-là. Chaque élément est de la forme (C, E), où C est le concept, et E est son expression équivalente après traitement
> - ResFinal : liste des résultats lorsqu'on a traité tous les concepts de la Tbox. Chaque élément est de la forme (C, E), où C est le concept, et E est son expression équivalente après traitement

#### Résultat de la partie de tests :
```prolog
% `applique_def_Tbox` sur tous les conceptions non atomiques :
?- applique_def_Tbox([auteur, editeur, parent, sculpteur],[],R).
R = [(auteur, and(personne, some(aEcrit, livre))), (editeur, and(personne, and(not(some(aEcrit, livre)), some(aEdite, livre)))), (parent, and(personne, some(aEnfant, anything))), (sculpteur, and(personne, some(aCree, sculpture)))].
% Ici, suite à la recursion, la liste de ResPartiel et de plus en plus grand.
% À la fin, on passe la valeur de ResPartiel à la variable ResFinal.
```

### `applique_nnf`
Le prédicat `applique_nnf` applique `nnf` sur toutes les expressions qui ont uniquement des concepts atomiques.

Pour parcourir et appliquer ce traitement sur la liste, on appelle `nnf` sur la première expression de la liste, puis on fait l'appel récursif sur le reste de la liste, en mettant à jour les listes de résultats.
> applique_nnf(L, ResPartiel, ResFinal) :
> - L : liste des axiomes de la Tbox, sous la forme (C, E), où C est le concept, et E est son expression équivalente avec uniquement des concepts atomiques 
> - ResPartiel : liste des résultats à cet instant/appel récursif-là. Chaque élément est de la forme (C, E), où C est le concept, et E est son expression équivalente après traitement
> - ResFinal : liste des résultats lorsqu'on a traité tous les concepts de la Tbox. Chaque élément est de la forme (C, E), où C est le concept, et E est son expression équivalente après traitement

#### Résultat de la partie de tests :
```prolog
?- applique_nnf([(auteur, and(personne, some(aEcrit, livre))), (editeur, and(personne, and(not(some(aEcrit, livre)), some(aEdite, livre)))), (parent, and(personne, some(aEnfant, anything))), (sculpteur, and(personne, some(aCree, sculpture)))],[],Rnnf).
Rnnf = [(auteur, and(personne, some(aEcrit, livre))), (editeur, and(personne, and(all(aEcrit, not(livre)), some(aEdite, livre)))), (parent, and(personne, some(aEnfant, anything))), (sculpteur, and(personne, some(aCree, sculpture)))].
```

### `traitement_Tbox`
Le prédicat `traitement_Tbox` permet d'obtenir tous les axiomes de la Tbox sous la forme de couples $(C, E)$, où C est un concept et E est son expression équivalente qui ne contient que des concepts atomiques et qui est sous forme normale négative.

Ce prédicat :
* récupère les concepts non atomiques des axiomes de la Tbox
* pour chaque concept, applique sa définition et d'autres jusqu'à n'avoir que des concepts atomiques
* met chaque expression sous forme normale négative 
> traitement_Tbox(Tbox) :
> - Tbox : liste des axiomes de la Tbox sous la forme de couples (C, E), où C est un concept et E est son expression équivalente qui ne contient que des concepts atomiques et qui est sous forme normale négative.

#### Résultat de la partie de tests :
```prolog
% Vérification de fonctionnement du prédicat `traitement_Tbox` en utilisant le résultat de `applique_nnf`:
?- traitement_Tbox([(auteur, and(personne, some(aEcrit, livre))), (editeur, and(personne, and(all(aEcrit, not(livre)), some(aEdite, livre)))), (parent, and(personne, some(aEnfant, anything))), (sculpteur, and(personne, some(aCree, sculpture)))]).
true.
```

### `applique_def_Abox`
Le prédicat `applique_def_Abox` appelle `applique_Tbox` sur tous les concepts de la Abox.

On récupère les expressions de toutes les instances de la Abox, et pour chacune, on récupère l'expression équivalente avec uniquement des concepts atomiques en appelant `applique_Tbox`. Pour parcourir et appliquer ce traitement sur la liste, on effectue le traitement sur le premier élément de la liste, puis on fait l'appel récursif sur le reste de la liste, en mettant à jour les listes de résultats.

Il prend en paramètres la liste des assertions de concept de la Abox, la liste des axiomes de la Tbox étendue, une liste partielle de résultats et une liste finale de résultats.
> applique_def_Abox(L, Tbox, ResPartiel, ResFinal) :
> - L : liste des assertions de concept de la Abox. Chaque élément est de la forme (I, C), où I est une instance et C est le concept
> - Tbox : liste contenant tous les axiomes de la Tbox étendue. Chaque élément est de la forme (C, E), où C est un concept non atomique et E est son expression équivalente qui ne contient que des concepts atomiques et sous forme normale négative
> - ResPartiel : liste des résultats à cet instant/appel récursif-là. Chaque élément est de la forme (I, E), où I est une instance, et E est l'expression équivalente du concept C après traitement
> - ResFinal : liste des résultats lorsqu'on a traité toutes les assertions de concept de la Abox. Chaque élément est de la forme (I, E), où I est une instance, et E est l'expression équivalente du concept C après traitement
#### Partie de tests
Ce prédicat est utilisé par le prédicat suivant `traitement_Abox`, il suffit donc de vérifier la fonctionnalité de ce dernier.


### `applique_Tbox`
Déploiement de Tbox en utilisant le résultat de `traitement_Tbox` quand on utilise le prédicat `premiere_etape` pour éviter de rappeler `applique_def` encore une fois.

> ```prolog
> % La forme de définition :
> applique_Tbox(proposition, Tbox, proposition_res).
> ```

### `traitement_Abox`
Le prédicat `traitement_Abox` permet d'obtenir toutes les assertions de concept de la Abox sous la forme de couples (I, E), où I est une instance et E est son expression équivalente à son concept qui ne contient que des concepts atomiques et qui est sous forme normale négative, et toutes les assertions de rôle de la Abox.

Il traite la liste des assertions de concept Abi et la liste des assertions de rôle Abr de la façon suivante :
- `Abi` : liste contenant les assertions de concept
  * récupère les assertions de concept sous la forme de couple (I, C)
  * pour chaque concept, applique sa définition et d'autres jusqu'à n'avoir que des concepts atomiques
  * met chaque expression sous forme normale négative
- `Abr` : liste contenant les assertions de rôles
  * récupère les assertions de concept sous la forme de tuple (A, B, R)

> traitement_Abox(Tbox, Abi, Abr) :
> - `Tbox` : liste de tuples (C, E), résultat de `traitement_Tbox`
> - `Abi` : liste des assertions de concept de la Abox après traitement. Chaque élément est de la forme (I, E), où I est une instance, et E l'expression équivalente à son concept
> - `Abr` : liste des assertions de rôle de la Abox. Chaque élément est de la forme (A, B, R), où A et B sont des instances, et R un rôle

#### Résultat de la partie de tests :
```prolog
?- traitement_Abox(Abi,Abr).
Abi = [(david, sculpture), (joconde, objet), (michelAnge, personne), (sonnets, livre), (vinci, personne)],
Abr = [(michelAnge, david, aCree), (michelAnge, sonnets, aEcrit), (vinci, joconde, aCree)].
```

### `premiere_etape`
On résume tous les prédicats écrits dans cette partie et arrive à finaliser la première étape de notre démonstrateur, qui est le traitement de la Tbox et le traitement de la Abox.

> premiere_etape(Tbox, Abi, Abr)
> - `Tbox` : le résultat du prédicat `traitement_Tbox`
> - `Abi` : tuples (instance, concept), résultat du `traitement_Abox`
> - `Abr` : tuples (instance1, instance2, rôle), résultat du `traitement_Abox`

#### Résultat de la partie de tests :
```prolog
?- premiere_etape(Tbox,Abi,Abr).
Tbox = [(auteur, and(personne, some(aEcrit, livre))), (editeur, and(personne, and(all(aEcrit, not(livre)), some(aEdite, livre)))), (parent, and(personne, some(aEnfant, anything))), (sculpteur, and(personne, some(aCree, sculpture)))],
Abi = [(david, sculpture), (joconde, objet), (michelAnge, personne), (sonnets, livre), (vinci, personne)],
Abr = [(michelAnge, david, aCree), (michelAnge, sonnets, aEcrit), (vinci, joconde, aCree)].
```

## Partie II : Saisie de la proposition à démontrer 
Une fois le traitement de la base de connaissances terminé, on traite la proposition à prouver entrée par l'utilisateur et fait également en sorte que la proposition ne contienne que des concepts atomiques. Nous considérons seulement deux types de propositions à prouver : 
- prouver qu'une instance appartient à un certain concept `(i : C)`
- ou qu'il n'y a pas d'intersection entre deux concepts `(C1 ⊓ C2 ⊑ ⊥ )`.

Depuis cette partie, on utilise une autre paire de Tbox et Abox pour tester nos prédicats. Les Tbox/Abox sont enregistrés dans le fichier "ex3td4.pl" et sont traduits de l'exo3 du TD4, donc le "eli et eon".
### `deuxieme_etape`
On commence par définir le prédicat final de cette partie, qui révèle notre objectif. L'idée principale est d'écouter les entrées de l'utilisateur puis d'appeler le prédicat correspondant.

> ```prolog
> deuxieme_etape(Abi,Abi1,Tbox) :- saisie_et_traitement_prop_a_demontrer(Abi,Abi1,Tbox).
> ```
> - Tbox : le résultat du prédicat `premiere_etape`
> - Abi : liste de tuples (instance, concept), résultat du `premiere_etape`
> - Abr : liste de tuples (instance1, instance2, rôle), résultat du `premiere_etape`
#### Résultat de la partie de tests :
```prolog
% testé en utilisant "ex3td4.pl" et les résultat des requêtes précedentes :
?- premiere_etape(Tbox,Abi,Abr).
Tbox = [(attiranceExcHomme, all(amant, homme)), (femme, not(homme)), (femmeHetero, and(not(homme), all(amant, homme))), (travesti, and(homme, habilleEnFemme))],
Abi = [(eli, and(not(homme), all(amant, homme))), (eon, habilleEnFemme)],
Abr = [(eli, eon, amant)].

?- deuxieme_etape([(eli, and(not(homme), all(amant, homme))), (eon, habilleEnFemme)],Abi1,[(attiranceExcHomme, all(amant, homme)), (femme, not(homme)), (femmeHetero, and(not(homme), all(amant, homme))), (travesti, and(homme, habilleEnFemme))]).
Abi1 = [(eli, and(not(homme), all(amant, homme))), (eon, habilleEnFemme), (eon, or(not(homme), not(habilleEnFemme)))].
```

### `acquisition_prop_type1`
Lire le premier type de proposition. Les étapes sont les suivantes : 
* lecture de l'instance `I`
* lecture du concept/de l'expression `C`
* vérification du concept `C`
* application sur `not(C)`, des axiomes de la Tbox traitée, jusqu'à n'avoir que des concepts atomiques
* mise sous forme normale négative 
* récupérer la liste de l'Abox étendue : `Abi1` = `Abi` + la nouvelle proposition
> ```prolog
> acquisition_prop_type1(Abi, Abi1, Tbox) :- 
> nl, write('Veuillez entrer le nom de l''instance :'), nl, read(I),
> nl, write('Veuillez entrer le concept ou l''expression de cette instance :'), nl, read(C), concept(C),
> applique_Tbox(not(C), Tbox, E), nnf(E, Res), concat(Abi, [(I, Res)], Abi1),!.
> ```
#### Partie de tests :
Testé en utilisant "ex3td4.pl" ; voyez le test du prédicat `programme` dans la partie III.

### `acquisition_prop_type2`
Lire le deuxième type de proposition. Les étapes sont les suivantes : 
* lecture du premier concept `C1`, puis du deuxième concept `C2` 
* vérification des concepts `C1` et `C2` 
* application sur `not(and(C1, C2))`, des axiomes de la Tbox traitée, jusqu'à n'avoir que des concepts atomiques 
* mise sous forme normale négative 
* récupérer la liste de l'Abox étendue : `Abi1` = `Abi` + la nouvelle proposition

> ```prolog
> acquisition_prop_type2(Abi, Abi1, Tbox) :-
> nl, write('Veuillez entrer le premier concept ou expression de la proposition :'), nl, read(C1), concept(C1),
> nl, write('Veuillez entrer le deuxième concept ou expression de la proposition :'), nl, read(C2), concept(C2),
> applique_Tbox(not(and(C1, C2)), Tbox, E), nnf(E, Res), genere(I), concat(Abi, [(I, Res)], Abi1),!.
> ```
#### Partie de tests :
On n'a pas testé ce prédicat.


## Partie III : Démonstration de la proposition
On ajoute la négation de la proposition fournie par l'utilisateur à la ABox pour en déduire la contradiction, prouvant ainsi l'établissement de la proposition. Enfin, nous utilisons le prédicat `programme` pour relier les trois étapes de preuve que nous avons implémentées pour former un démonstrateur utilisable. Pour le test de cette partie, voyez le test du prédicat `programme`.
### `tri_Abox`
Trier les propositions dans l'ABox étendue et ajoutez-les à leurs listes de propositions respectives. 

Étant donné une proposition, nous vérifions d'abord si la relation et/ou les concepts qu'elle contient sont conformes à la sémantique (sont dans notre base de connaissances), puis appelons le prédicat `concat` pour l'ajouter à une liste de propositions correspondantes, puis effectuons la récursion suivante sous forme d'unification. En termes d'implémentation du code, nous prenons la proposition en tête de la liste de propositions originale et la traitons, puis récurrons sur le corps, jusqu'à atteindre la liste vide.

Le prédicat `tri_Abox` s'occupe d'initialiser les listes `Lie`, `Lpt`, `Li`, `Lu` et `Ls`, et d'appeler le prédicat `tri_Abox_rec` qui s'occupe du tri récursif.

> Nous utilisons un exemple pour illustrer la conception du prédicat `tri_Abox`. Supposons que nous souhaitions ajouter une proposition `and(C1,C2)` aux listes de proposition :
>
> ```prolog
> tri_Abox(Abi, Lie, Lpt, Li, Lu, Ls) :- tri_Abox_rec(Abi, [], [], [], [], [], Lie, Lpt, Li, Lu, Ls),!.
> tri_Abox_rec([], Lie, Lpt, Li, Lu, Ls, Lie, Lpt, Li, Lu, Ls).
> tri_Abox_rec([(I, and(C1, C2)) | Abi], Lie1, Lpt1, Li1, Lu1, Ls1, Lie2, Lpt2, Li2, Lu2, Ls2) :- concept(C1), concept(C2), concat(Li1, [(I, and(C1, C2))], LiPartiel), tri_Abox_rec(Abi, Lie1, Lpt1, LiPartiel, Lu1, Ls1, Lie2, Lpt2, Li2, Lu2, Ls2),!.                                                   
> ```
> - "Lie1, Lpt1, Li1, Lu1, Ls1" : les listes originales contenant différents types de propositions avant le traitement de l'instance `I:and(C1,C2)`
> - "Lie2, Lpt2, Li2, Lu2, Ls2" : les listes contenant différents types de propositions après le traitement de l'instance `I:and(C1,C2)`

### `resolution`
La racine de l'arbre de démonstration.
> ```prolog
> resolution(Lie, Lpt, Li, Lu, Ls, Abr) :- complete_some(Lie, Lpt, Li, Lu, Ls, Abr),!.
> ```
> On commence par appliquer la règle `some`.

On peut également remarquer qu'il est possible que la proposition à démontrer n'ajoute aucune assertion de concept qui utilise les règles `some`, `and`, `all` ou `or`. Dans ce cas, il suffit de vérifier une seule fois la présence d'un clash, pour déterminer si le démonstrateur peut démontrer la proposition d'entrée ou non.
> ```prolog
> resolution([], [], [], [], Ls, Abr) :- test_clash([], [], [], [], Ls, Abr),!.
> ```
### `test_clash`
Après avoir appliqué chaque règle, on détermine si un clash se produit.

Comment déterminer un clash:
* s'il contient à la fois `a:C` et `a:not(C)` dans `Ls` (la liste de concepts atomiques) -> clash donc stop 
* sinon, on retourne au nœud racine (`resolution`).
> ```prolog
> test_clash(_, _, _, _, Ls, _) :- member((A, C), Ls), nnf(not(C),Cnnf), member((A, Cnnf), Ls), nl, write('Clash'), nl,!.
> test_clash(Lie, Lpt, Li, Lu, Ls, Abr) :- length(Lie, N), N > 0, nl, write('Nouvelle résolution'), nl, resolution(Lie, Lpt, Li, Lu, Ls, Abr),!.
> test_clash(Lie, Lpt, Li, Lu, Ls, Abr) :- length(Lpt, N), N > 0, nl, write('Nouvelle résolution'), nl, resolution(Lie, Lpt, Li, Lu, Ls, Abr),!.
> test_clash(Lie, Lpt, Li, Lu, Ls, Abr) :- length(Li, N), N > 0, nl, write('Nouvelle résolution'), nl, resolution(Lie, Lpt, Li, Lu, Ls, Abr),!.
> test_clash(Lie, Lpt, Li, Lu, Ls, Abr) :- length(Lu, N), N > 0, nl, write('Nouvelle résolution'), nl, resolution(Lie, Lpt, Li, Lu, Ls, Abr),!.
> ```
> On doit vérifier qu'au moins une des listes qui contient des instances de concept utilisant les opérateurs `some`, `and`, `all` ou `or`, ne soit pas vide, car si elles le sont toutes, il ne faut pas créer une nouveau noeud de résolution, mais plutôt l'arrêter.
### `complete_some`
La règle `some`.
* s'il n'y a pas d'assertion du type `a:some(R, C)`, on traite les règles `and`
* sinon, on génère `b`, on ajoute `<a,b>:R` dans `Abr` et `b:C` dans `Ls`, et on teste s'il y a un clash.

> ```prolog
> complete_some([], Lpt, Li, Lu, Ls, Abr) :- transformation_and([], Lpt, Li, Lu, Ls, Abr),!.
> complete_some([(A, some(R, C)) | Lie], Lpt, Li, Lu, Ls, Abr) :- genere(B), concat(Abr, [(A, B, R)], Abr1),
>                                                                 evolue((B, C), Lie, Lpt, Li, Lu, Ls, Lie1, Lpt1, Li1, Lu1, Ls1),
>                                                                 affiche_evolution_Abox(Ls, [(A, some(R, C)) | Lie], Lpt, Li, Lu, Abr, Ls1, Lie1, Lpt1, Li1, Lu1, Abr1),
>                                                                test_clash(Lie1, Lpt1, Li1, Lu1, Ls1, Abr1),!.
> ```
#### Partie de tests :
On n'a pas testé ce prédicat.
### `transformation_and`
La règle `and`.
* s'il n'y a pas d'assertion du type `a:and(C, D)`, on traite les règles `all`
* sinon, on ajoute `a:C` et `a:D` dans `Ls`, on teste s'il y a un clash, et on récurre sur le reste des règles dans la liste de propositions originale.
> ```prolog
> transformation_and(Lie, Lpt, [], Lu, Ls, Abr) :- deduction_all(Lie, Lpt, [], Lu, Ls, Abr),!.
> transformation_and(Lie, Lpt, [(A, and(C, D)) | Li], Lu, Ls, Abr) :- evolue((A, C), Lie, Lpt, Li, Lu, Ls, Lie1, Lpt1, Li1, Lu1, Ls1),
>                                                                    evolue((A, D), Lie1, Lpt1, Li1, Lu1, Ls1, Lie2, Lpt2, Li2, Lu2, Ls2),
> % Le prédicat suivant utilise le résultat du traitement renvoyé par le prédicat précédent.
>                                                                    affiche_evolution_Abox(Ls, Lie, Lpt, [(A, and(C, D)) | Li], Lu, Abr, Ls2, Lie2, Lpt2, Li2, Lu2, Abr),
>                                                                    test_clash(Lie2, Lpt2, Li2, Lu2, Ls2, Abr),!.
> ```
### `deduction_all`
La règle `all`.
* s'il n'y a pas d'assertion du type `a:all(R, C)`, on traite les règles `or`
* sinon, on cherche tous les `b` tels que `a:all(R, C)` est dans `Lpt` et `<a,b>:R` est dans `Abr`, on ajoute `b:C` dans `Ls`, on enlève la règle `a:all(R, C)`, et on teste s'il y a un clash.
> ```prolog
> deduction_all(Lie, [], Li, Lu, Ls, Abr) :- transformation_or(Lie, [], Li, Lu, Ls, Abr),!.
> deduction_all(Lie, Lpt, Li, Lu, Ls, Abr) :- member((A, all(R, C)), Lpt), member((A, B, R), Abr), 
>                                            evolue((B, C), Lie, Lpt, Li, Lu, Ls, Lie1, Lpt, Li1, Lu1, Ls1),
>                                            enleve((A, all(R, C)), Lpt, Lpt2),
>                                            affiche_evolution_Abox(Ls, Lie, Lpt, Li, Lu, Abr, Ls1, Lie1, Lpt2, Li1, Lu1, Abr),
>                                            test_clash(Lie1, Lpt2, Li1, Lu1, Ls1, Abr).
> ```
### `transformation_or`
La règle `or`.
* s'il n'y a pas d'assertion du type `a:or(C, D)` (et qu'il n'y a pas eu de clash depuis), il y a donc erreur de résolution
* sinon, dans un noeud de résolution, on ajoute `a:C` dans `Ls` et on teste s'il y a un clash, et dans un autre noeud, on ajoute `a:D` et on teste s'il y a un clash. 
> ```prolog
> transformation_or(Lie, Lpt, Li, [(A, or(C, D)) | Lu], Ls, Abr) :- evolue((A, C), Lie, Lpt, Li, Lu, Ls, Lie1, Lpt1, Li1, Lu1, Ls1),
>                                                                  affiche_evolution_Abox(Ls, Lie, Lpt, Li, [(A, or(C, D)) | Lu], Abr, Ls1, Lie1, Lpt1, Li1, Lu1, Abr),
>                                                                  test_clash(Lie1, Lpt1, Li1, Lu1, Ls1, Abr),
>                                                                  evolue((A, D), Lie, Lpt, Li, Lu, Ls, Lie2, Lpt2, Li2, Lu2, Ls2),
>                                                                 affiche_evolution_Abox(Ls, Lie, Lpt, Li, [(A, or(C, D)) | Lu], Abr, Ls2, Lie2, Lpt2, Li2, Lu2, Abr),
>                                                                 test_clash(Lie2, Lpt2, Li2, Lu2, Ls2, Abr),!.
> ```
### `evolue`
Mettre à jour les listes des différents types de propositions, divisées en fonction du type/de la forme des instances qu'elles contiennent (`some`, `all`, `and`, `or`, `not` ou "atomique"), en ajoutant une nouvelle instance dans la bonne liste. 

Si on souhaite ajouter une proposition d'un certain type aux listes de proposition originales, on utilise le prédicat `concat` pour l'ajouter à la liste correspondante, puis transmet la liste mise à jour à une nouvelle variable.

> Un exemple :
> 
> ```prolog
> evolue((A, some(R, C)), Lie, Lpt, Li, Lu, Ls, Lie1, Lpt, Li, Lu, Ls) :- concat(Lie, [(A, some(R, C))], Lie1),!.
> ```
> - les 5 premiers paramètres "Lie, Lpt, Li, Lu, Ls" : les listes originales contenant différents types de propositions
> - "Lie1" : la liste qui change (elle est le résultat de la concaténation de `Lie` avec la nouvelle instance ajoutée)
> - les paramètres restes "Lpt, Li, Lu, Ls" : les listes qui n'ont pas changé dans cette mise à jour (mais peuvent changer dans les autres situations)
### `affiche_evolution_Abox`
Afficher l'Abox étendue avant la mise à jour et l'Abox étendue après la mise à jour.

>```prolog
> affiche_evolution_Abox(Ls1, Lie1, Lpt1, Li1, Lu1, Abr1, Ls2, Lie2, Lpt2, Li2, Lu2, Abr2) :-
>    nl, write('Ancienne Abox'), nl, affiche_lst_inst(Ls1), affiche_lst_inst(Lie1), affiche_lst_inst(Lpt1), affiche_lst_inst(Li1), affiche_lst_inst(Lu1), affiche_lst_inst(Abr1),
>    nl, write('Nouvelle Abox'), nl, affiche_lst_inst(Ls2), affiche_lst_inst(Lie2), affiche_lst_inst(Lpt2), affiche_lst_inst(Li2), affiche_lst_inst(Lu2), affiche_lst_inst(Abr2),!.
>```
### `troisieme_etape`
> ```prolog
> troisieme_etape(Abi1,Abr) :- tri_Abox(Abi1,Lie,Lpt,Li,Lu,Ls),
>                            resolution(Lie,Lpt,Li,Lu,Ls,Abr),
>                            nl,write('Youpiiiiii, on a demontre la proposition initiale !!!').
> ```

### `programme`
Entrée de notre programme de démonstrateur, appelant les trois prédicats `premiere_etape`, `deuxieme_etape` et `troisieme_etape`. 
> ```prolog
> programme :- premiere_etape(Tbox,Abi,Abr),
>     % Le prédicat suivant utilise le résultat du traitement renvoyé par le prédicat précédent.
>             deuxieme_etape(Abi,Abi1,Tbox),
>             troisieme_etape(Abi1,Abr).
> ```
#### Résultat de la partie de tests :
Un processus de preuve complet :
```prolog
?- programme.

Entrez le numero du type de proposition que vous voulez demontrer :
1 Une instance donnee appartient a un concept donne.
2 Deux concepts n"ont pas d"elements en commun(ils ont une intersection vide).
|: 1.

Veuillez entrer le nom de l'instance :
|: eon.

Veuillez entrer le concept ou l'expression de cette instance :
|: travesti.

% On applique la règle and :
Ancienne Abox
eon:habilleEnFemme
eli:¬homme⊓∀amant.homme
eon:¬homme⊔¬habilleEnFemme
eli,eon:amant

Nouvelle Abox
eon:habilleEnFemme
eli:¬homme
eli:∀amant.homme
eon:¬homme⊔¬habilleEnFemme
eli,eon:amant

% On applique la règle all :
Ancienne Abox
eon:habilleEnFemme
eli:¬homme
eli:∀amant.homme
eon:¬homme⊔¬habilleEnFemme
eli,eon:amant

Nouvelle Abox
eon:habilleEnFemme
eli:¬homme
eon:homme
eon:¬homme⊔¬habilleEnFemme
eli,eon:amant

% On applique la règle or, maintenant il y a deux feuilles :
Ancienne Abox
eon:habilleEnFemme
eli:¬homme
eon:homme
eon:¬homme⊔¬habilleEnFemme
eli,eon:amant

Nouvelle Abox
eon:habilleEnFemme
eli:¬homme
eon:homme
eon:¬homme
eli,eon:amant

Clash

Ancienne Abox
eon:habilleEnFemme
eli:¬homme
eon:homme
eon:¬homme⊔¬habilleEnFemme
eli,eon:amant

Nouvelle Abox
eon:habilleEnFemme
eli:¬homme
eon:homme
eon:¬habilleEnFemme
eli,eon:amant

Clash

Youpiiiiii, on a demontre la proposition initiale !!!
true.
```
## Conclusion
Dans ce projet, nous avons implémenté un démonstrateur via un programme Prolog, implémenté une série de prédicats basés sur les idées de récursion et d'unification, et effectué des tests pour vérifier la fonctionnement du démonstrateur.
