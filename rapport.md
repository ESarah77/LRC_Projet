# LRC_Projet
Projet de LRC : Ecriture en Prolog d’un démonstrateur basé sur l’algorithme des tableaux pour la logique de description ALC

## Partie 1 : Etape préliminaire de vérification et de mise en forme de la Tbox et de la Abox

### `concept`
Le prédicat `concept` permet de vérifier la correction syntaxique de toutes les expresssions d'entrée (Tbox, Abox et entrée de l'utilisateur).

Pour implémenter ce prédicat, nous nous sommes basées sur la définition récursive du concept, décrite dans la section "Quelques rappels préliminaires/I. Logique de description ALC/3. Grammaire", qui dit qu'un concept est :
    - soit un concept atomique (ou top ou bottom, qui sont définis comme concept atomique dans ce projet)
    - soit une expression not(concept)
    - soit une expression and(concept, concept)
    - soit une expression or(concept, concept)
    - soit une expression some(role, concept)
    - ou soit une expression all(role, concept).
Il prend donc en paramètre une expression, et renvoie true s'il s'agit bien d'un concept.
concept(E):
    * E : expression dont on veut savoir s'il s'agit bien d'un concept

(Description des tests réalisés)


### `pas-autoref`
Le prédicat `pas-autoref` permet de vérifier si un concept n'est pas auto-référent. Ce prédicat sera notamment utilisé plus tard pour le traitement de la Tbox, qui vont vérifier pour toutes leurs axiomes, si elles sont auto-référentes.


Pour une définition de concept de la Tbox de la forme C ≡ E :
    - récursivement, on applique la définition E du concept C
        * soit E est un concept atomique, d'après la définition, on sait que C est un concept non atomique, donc ils sont forcément différent, donc il n'y a pas d'autoréférence
        * soit E est un concept non atomique, il faut vérifier qu'il ne s'agit pas de C, et s'ils sont bien différents, on continue la récursion de `pas-autoref` sur la définition du concept non atomique E
        * soit E commence par un opérateur et on applique récursivement `pas-autoref` sur les concepts de cette opération (deux appels récursifs sur chacun des membres s'il s'agit d'un opérateur `and` ou `or`, un seul appel récursif sur le deuxième membre s'il s'agit d'un opérateur `some` ou `all`).
Il prend en paramètre un concept et son expression conceptuelle équivalente dans la Tbox, et renvoie true s'il n'est pas auto-référent.
pas-autoref(C, E):
    - C : concept
    - E : expression équivalente du concept C

#### Description des tests réalisés
- tests de toutes les définitions dans `equiv` du fichier ta.pl
- on modifie ta.pl en définissant `sculpture` comme un concept non atomique et en ajoutant sa définition dans `equiv` (cf exemple de Tbox circulaire de l'énoncé) et aussi un nom de rôle `creePar`（seulement pour vérifier le fonctionnement du prédicat `autoref`.

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
Le prédicat `pas-autoref` permet de vérifier si un concept est auto-référent. 

Il s'agit de la négation du prédicat `pas-autoref`.
Il prend en paramètre un concept et son expression conceptuelle équivalente dans la Tbox, et renvoie true s'il est auto-référent.
autoref(C, E):
    - C : concept
    - E : expression équivalente du concept C

(Description des tests réalisés)
pareil que `pas-autoref`, on vérifie juste qu'il s'agit bien de la négation


### `applique_def`
Le prédicat `applique_def` applique la définition d'un concept et d'autres définitions de la Tbox, jusqu'à ce qu'il n'y ait plus que des concepts atomiques.

Il applique de manière récursive la définition du concept. De même, si l'expression du concept comporte des opérateurs, il applique `applique_def` de manière récursive sur tous les membres des opérateurs qui sont des concepts. De plus, on appelle `concept` pour toujours vérifier la correction syntaxique des expressions.
Il prend en paramètre un concept et un résultat.
applique_def(concept, res) :
    - concept : concept dont on veut trouver l'expression équivalente avec uniquement des concepts atomiques
    - res : expression équivalente de concept qu'on a trouvé

(Description des tests réalisés)


### `applique_def_Tbox`
Le prédicat `applique_def_Tbox` applique `applique_def` sur tous les concepts de la Tbox.

On récupère les expressions de tous les concepts de la Tbox, et pour chacune, on récupère l'expression équivalente avec uniquement des concepts atomiques en appelant `applique_def`. On vérifie également pour chaque concept de la Tbox qu'il n'est pas auto-référent en appelant `pas-autoref`. Pour parcourir et appliquer ce traitement sur la liste, on effectue le traitement sur le premier élément de la liste, puis on fait l'appel récursif sur le reste de la liste, en mettant à jour les listes de résultats.
Il prend en paramètres la liste des concepts de la Tbox, une liste partielle de résultats et une liste finale de résultats.
applique_def_Tbox(L, ResPartiel, ResFinal) :
    - L : liste des concepts (non atomiques) de la Tbox
    - ResPartiel : liste des résultats à cet instant/appel récursif-là. Chaque élément est de la forme (C, E), où C est le concept, et E est son expression équivalente après traitement
    - ResFinal : liste des résultats lorsqu'on a traité tous les concepts de la Tbox. Chaque élément est de la forme (C, E), où C est le concept, et E est son expression équivalente après traitement

(Description des tests réalisés)


### `applique_nnf`
Le prédicat `applique_nnf` applique `nnf` sur toutes les expressions qui ont uniquement des concepts atomiques.

Pour parcourir et appliquer ce traitement sur la liste, on appelle `nnf` sur la première expression de la liste, puis on fait l'appel récursif sur le reste de la liste, en mettant à jour les listes de résultats.
applique_nnf(L, ResPartiel, ResFinal) :
    - L : liste des axiomes de la Tbox, sous la forme (C, E), où C est le concept, et E est son expression équivalente avec uniquement des concepts atomiques 
    - ResPartiel : liste des résultats à cet instant/appel récursif-là. Chaque élément est de la forme (C, E), où C est le concept, et E est son expression équivalente après traitement
    - ResFinal : liste des résultats lorsqu'on a traité tous les concepts de la Tbox. Chaque élément est de la forme (C, E), où C est le concept, et E est son expression équivalente après traitement

(Description des tests réalisés)


### `traitement_Tbox`
Le prédicat `traitement_Tbox` permet d'obtenir tous les axiomes de la Tbox sous la forme de couples (C, E), où C est un concept et E est son expression équivalente qui ne contient que des concepts atomiques et qui est sous forme normale négative.

Ce prédicat :
    * récupère les concepts non atomiques des axiomes de la Tbox
    * pour chaque concept, applique sa définition et d'autres jusqu'à n'avoir que des concepts atomiques
    * met chaque expression sous forme normale négative 
traitement_Tbox(Tbox) :
    Tbox : liste des axiomes de la Tbox sous la forme de couples (C, E), où C est un concept et E est son expression équivalente qui ne contient que des concepts atomiques et qui est sous forme normale négative.

(Description des tests réalisés)


### `applique_def_Abox`
Le prédicat `applique_def_Abox` applique `applique_def` sur tous les concepts de la Abox.

On récupère les expressions de toutes les instances de la Abox, et pour chacune, on récupère l'expression équivalente avec uniquement des concepts atomiques en appelant `applique_def`. Pour parcourir et appliquer ce traitement sur la liste, on effectue le traitement sur le premier élément de la liste, puis on fait l'appel récursif sur le reste de la liste, en mettant à jour les listes de résultats.
Il prend en paramètres la liste des assertions de concept de la Abox, une liste partielle de résultats et une liste finale de résultats.
applique_def_Abox(L, ResPartiel, ResFinal) :
    - L : liste des assertions de concept de la Abox. Chaque élément est de la forme (I, C), où I est une instance et C est le concept
    - ResPartiel : liste des résultats à cet instant/appel récursif-là. Chaque élément est de la forme (I, E), où I est une instance, et E est l'expression équivalente du concept C après traitement
    - ResFinal : liste des résultats lorsqu'on a traité toutes les assertions de concept de la Abox. Chaque élément est de la forme (I, E), où I est une instance, et E est l'expression équivalente du concept C après traitement

(Description des tests réalisés)


### `traitement_Abox`
Le prédicat `traitement_Abox` permet d'obtenir toutes les assertions de concept de la Abox sous la forme de couples (I, E), où I est une instance et E est son expression équivalente à son concept qui ne contient que des concepts atomiques et qui est sous forme normale négative, et toutes les assertions de rôle de la Abox.

Il traite la liste des assertions de concept Abi et la liste des assertions de rôle Abr de la façon suivante :
    - Abi : liste contenant les assertions de concept
        * récupère les assertions de concept sous la forme de couple (I, C)
        * pour chaque concept, applique sa définition et d'autres jusqu'à n'avoir que des concepts atomiques
        * met chaque expression sous forme normale négative
    - Abr : liste contenant les assertions de rôles
        * récupère les assertions de concept sous la forme de tuple (A, B, R) 
traitement_Abox(Abi, Abr) :
    - Abi : liste des assertions de concept de la Abox après traitement. Chaque élément est de la forme (I, E), où I est une instance, et E l'expression équivalente à son concept
    - Abr : liste des assertions de rôle de la Abox. Chaque élément est de la forme (A, B, R), où A et B sont des instances, et R un rôle

(Description des tests réalisés)


### `premiere_etape`
(Description du rôle de ce prédicat)

(Explication de l'implémentation + Paramètres)

(Description des tests réalisés)
