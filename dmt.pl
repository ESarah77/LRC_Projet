%--------Utilitaires fournis-----------
concat([],L1,L1).
concat([X|Y],L1,[X|L2]) :- concat(Y,L1,L2).

enleve(X,[X|L],L) :-!.
enleve(X,[Y|L],[Y|L2]) :- enleve(X,L,L2).

compteur(1).

genere(Nom) :-  compteur(V),nombre(V,L1),
                concat([105,110,115,116],L1,L2),
                V1 is V+1,
                dynamic(compteur/1),
                retract(compteur(V)),
                dynamic(compteur/1),
                assert(compteur(V1)),nl,nl,nl,
                name(Nom,L2).

nombre(0,[]).
nombre(X,L1) :- R is (X mod 10),
                Q is ((X-R)//10),
                chiffre_car(R,R1),
                char_code(R1,R2),
                nombre(Q,L),
                concat(L,[R2],L1).

chiffre_car(0,'0').
chiffre_car(1,'1').
chiffre_car(2,'2').
chiffre_car(3,'3').
chiffre_car(4,'4').
chiffre_car(5,'5').
chiffre_car(6,'6').
chiffre_car(7,'7').
chiffre_car(8,'8').
chiffre_car(9,'9').

%--------------Requetes----------------
% Tbox original
% [(sculpteur,and(personne,some(aCree,sculpture))),
% (auteur,and(personne,some(aEcrit,livre))),
% (editeur,and(personne,and(not(some(aEcrit,livre)),some(aEdite,livre)))),
% (parent,and(personne,some(aEnfant,anything)))]

% Abox original
%[(michelAnge,personne), (david,sculpture), (sonnets,livre), (vinci,personne), (joconde,objet)]
%[(michelAnge, david, aCree), (michelAnge, sonnet, aEcrit), (vinci, joconde, aCree)]

%--------------Partie I----------------
% Mettre sous forme normale negative
% récursion gauche: La cible la plus à gauche dans le corps d’une règle est la même
% que la tête de la règle. aurait du pb mais pas grave.
nnf(not(and(C1,C2)),or(NC1,NC2)):- nnf(not(C1),NC1), nnf(not(C2),NC2),!.
nnf(not(or(C1,C2)),and(NC1,NC2)):- nnf(not(C1),NC1), nnf(not(C2),NC2),!.
nnf(not(all(R,C)),some(R,NC)):- nnf(not(C),NC),!.
nnf(not(some(R,C)),all(R,NC)):- nnf(not(C),NC),!.
nnf(not(not(X)),Y):- nnf(X,Y),!.
nnf(not(X),not(X)):-!.
nnf(and(C1,C2),and(NC1,NC2)):- nnf(C1,NC1),nnf(C2,NC2),!.
nnf(or(C1,C2),or(NC1,NC2)):- nnf(C1,NC1), nnf(C2,NC2),!.
nnf(some(R,C),some(R,NC)):- nnf(C,NC),!.
nnf(all(R,C),all(R,NC)) :- nnf(C,NC),!.
nnf(X,X).

% correction syntaxique & semantique

% concept(X,Lres) :- concept().
% Faux: concept(X) :- setof(_,cnamea(_),L),member(X,L),!.
% car retourne L comme une var arbitraire, peut verifier dans mode trace

% concept(X) :- setof(Y,cnamea(Y),L),member(X,L),!.
% concept(X) :- setof(Y,cnamena(Y),L),member(X,L),!.

% concept(X) :- setof(X,iname(X),L),!.
% concept(X) :- setof(X,rname(X),L),!.

% OK :
    % * True si on teste concept avec en paramètre un identificateur de concept (par exemple : auteur)
    % * False si on teste concept avec en paramètre un identificateur qui n'est pas un concept (ex : michelAnge)
    % * Renvoie bien une liste L avec tous les concepts dedans ( ex : setof(X, concept(X), L) )
concept(X) :- cnamea(X),!.
concept(X) :- cnamena(X),!.
concept(not(C)) :- concept(C),!.
concept(and(C1, C2)) :- concept(C1), concept(C2),!.
concept(or(C1, C2)) :- concept(C1), concept(C2),!.
concept(some(R, C)) :- rname(R), concept(C),!.
concept(all(R, C)) :- rname(R), concept(C),!.

% ; pour "ou"

% pas-autoref :
% Pour une définition de concept de la Tbox de la forme C ≡ E, 
% par récursion, on applique les définitions des concepts non atomiques jusqu'à que l'on ne peut plus
% et on vérifie si ce n'est pas autoréférent 
% (application de pas-autoref sur E si c'est un concept atomique ou non atomique, ou application de pas-autoref sur C1 et C2 si E = op(C1,C2))
% Si on arrive à une expression sans opération (=seulement un concept), on arrive aux cas de base :
    % * soit E est un concept atomique, d'après la définition, on sait que C est un concept non atomique, donc ils sont forcément différent, 
    % donc il n'y a pas d'autoréférence
    % * soit E est un concept non atomique, il faut vérifier qu'il ne s'agit pas de C, et si c'est le cas,
    % on continue la récursion de pas-autoref sur la définition du concept non atomique E
% pas-autoref(_, C1) :- cnamea(C1),!.
pas-autoref(C, C1) :- cnamea(C1), C \= C1,!.
pas-autoref(C, C1) :- cnamena(C1), C \= C1, equiv(C1, E), pas-autoref(C, E),!.
pas-autoref(C, not(E)) :- concept(E), pas-autoref(C, E),!.
pas-autoref(C, and(C1, C2)) :- concept(C1), concept(C2), pas-autoref(C, C1), pas-autoref(C, C2),!.
pas-autoref(C, or(C1, C2)) :- concept(C1), concept(C2), pas-autoref(C, C1), pas-autoref(C, C2),!.
pas-autoref(C, some(R, C1)) :- rname(R), concept(C1), pas-autoref(C, C1),!.
pas-autoref(C, all(R, C1)) :- rname(R), concept(C1), pas-autoref(C, C1),!.

% autoref : il s'agit de la négation de pas-autoref
autoref(C, E) :- not(pas-autoref(C, E)),!.

% Mettre sous forme normale negative
% traitement-Tbox(Cx) :- concept-atomique(Cx); traitement-Tbox(Cx-qqch).

% applique_def(concept, res) : de manière récursive, applique la définition de concept et le met dans res
applique_def(C, C) :- cnamea(C),!.
applique_def(C, Res) :- cnamena(C), equiv(C, E), applique_def(E, Res),!.
applique_def(not(C), not(Res)) :- concept(C), applique_def(C, Res),!.
applique_def(and(C1, C2), and(Res1, Res2)) :- concept(C1), concept(C2), applique_def(C1, Res1), applique_def(C2, Res2),!.
applique_def(or(C1, C2), or(Res1, Res2)) :- concept(C1), concept(C2), applique_def(C1, Res1), applique_def(C2, Res2),!.
applique_def(some(R, C), some(R, Res)) :- rname(R), concept(C), applique_def(C, Res),!.
applique_def(all(R, C), all(R, Res)) :- rname(R), concept(C), applique_def(C, Res),!.

% applique_def_Tbox(Lc, Lpartiel, Lfinal) : appel applique_def sur tous les concepts de Lc,
% et ajoute le résultat courant dans la liste des résultats précédents
applique_def_Tbox([], L, L).
applique_def_Tbox([C | L], ResPartiel, ResFinal) :- equiv(C, E), pas-autoref(C, E),!, 
                                                    applique_def(C, ERes), concat(ResPartiel, [(C, ERes)], Res), 
                                                    applique_def_Tbox(L, Res, ResFinal),!.

% Résultat du part test :
% ?- applique_def_Tbox([auteur, editeur, parent, sculpteur],[],R).
% R = [(auteur, and(personne, some(aEcrit, livre))), (editeur, and(personne, and(not(some(aEcrit, livre)), some(aEdite, livre)))), (parent, and(personne, some(aEnfant, anything))), (sculpteur, and(personne, some(aCree, sculpture)))].


% applique_nnf(Lce, Lpartiel, Lfinal) : appel nnf sur tous les E des éléments de Lce, qui sont des couples (X,E),
% et ajoute le résultat courant dans la liste des résultats précédents
applique_nnf([], L, L).
applique_nnf([(X, E) | L], ResPartiel, ResFinal) :- nnf(E, Ennf), concat(ResPartiel, [(X, Ennf)], Res),
                                                    applique_nnf(L, Res, ResFinal),!.

% Résultat :
% ?- applique_nnf([(auteur, and(personne, some(aEcrit, livre))), (editeur, and(personne, and(not(some(aEcrit, livre)), some(aEdite, livre)))), (parent, and(personne, some(aEnfant, anything))), (sculpteur, and(personne, some(aCree, sculpture)))],[],Rnnf).
% Rnnf = [(auteur, and(personne, some(aEcrit, livre))), (editeur, and(personne, and(all(aEcrit, not(livre)), some(aEdite, livre)))), (parent, and(personne, some(aEnfant, anything))), (sculpteur, and(personne, some(aCree, sculpture)))].


% Tbox = résultat = [(CNA1, E1), (CNA2, E2), ...]
% traitement_Tbox : 
    % * récupère les concepts non atomiques
    % * pour chaque concept, applique sa définition et d'autres jusqu'à n'avoir que des concepts atomiques
    % * met chaque expression sous forme normale négative 
traitement_Tbox(Tbox) :- setof(C, cnamena(C), L), applique_def_Tbox(L, [], Ldef), applique_nnf(Ldef, [], Tbox),!.

% Résultat :
% ?- traitement_Tbox(Tbox).
% Tbox = [(auteur, and(personne, some(aEcrit, livre))), (editeur, and(personne, and(all(aEcrit, not(livre)), some(aEdite, livre)))), (parent, and(personne, some(aEnfant, anything))), (sculpteur, and(personne, some(aCree, sculpture)))].


applique_Tbox(C, _, C) :- cnamea(C),!.
applique_Tbox(C, Tbox, E) :- cnamena(C), member((C,E), Tbox),!.
applique_Tbox(not(C), Tbox, not(Res)) :- concept(C), applique_Tbox(C, Tbox, Res),!.
applique_Tbox(and(C1, C2), Tbox, and(Res1, Res2)) :- concept(C1), concept(C2), applique_Tbox(C1, Tbox, Res1), applique_Tbox(C2, Tbox, Res2),!.
applique_Tbox(or(C1, C2), Tbox, or(Res1, Res2)) :- concept(C1), concept(C2), applique_Tbox(C1, Tbox, Res1), applique_Tbox(C2, Tbox, Res2),!.
applique_Tbox(some(R, C), Tbox, some(R, Res)) :- rname(R), concept(C), applique_Tbox(C, Tbox, Res),!.
applique_Tbox(all(R, C), Tbox, all(R, Res)) :- rname(R), concept(C), applique_Tbox(C, Tbox, Res),!.

% applique_def_Abox(Lic, Lpartiel, Lfinal) : appel applique_def sur tous les concepts C de la liste Lic,
% où les éléments sont de la forme (I, C), et ajoute le résultat courant dans la liste des résultats précédents

applique_def_Abox([], _, L, L).
applique_def_Abox([(I, C) | L], Tbox, ResPartiel, ResFinal) :- applique_Tbox(C, Tbox, CRes), concat(ResPartiel, [(I, CRes)], Res),
                                                         applique_def_Abox(L, Tbox, Res, ResFinal),!.

% traitement_Abox :
    % - Abi : liste contenant les assertions de concept
    %     * récupère les assertions de concept sous la forme de couple (I, C)
    %     * pour chaque concept, applique sa définition et d'autres jusqu'à n'avoir que des concepts atomiques
    %     * met chaque expression sous forme normale négative
    % - Abr : liste contenant les assertions de rôles
    %     * récupère les assertions de concept sous la forme de tuple (A, B, R) 
traitement_Abox(Tbox, Abi, Abr) :- setof((I, C), inst(I, C), L), applique_def_Abox(L, Tbox, [], Ldef), applique_nnf(Ldef, [], Abi),
                             setof((A, B, R), instR(A, B, R), Abr),!.

% Résultats :
% ?- traitement_Abox(Abi,Abr).
% Abi = [(david, sculpture), (joconde, objet), (michelAnge, personne), (sonnets, livre), (vinci, personne)],
% Abr = [(michelAnge, david, aCree), (michelAnge, sonnets, aEcrit), (vinci, joconde, aCree)].


premiere_etape(Tbox, Abi, Abr) :- traitement_Tbox(Tbox), traitement_Abox(Tbox, Abi, Abr),!.

% Résultats :
% ?- premiere_etape(Tbox,Abi,Abr).
% Tbox = [(auteur, and(personne, some(aEcrit, livre))), (editeur, and(personne, and(all(aEcrit, not(livre)), some(aEdite, livre)))), (parent, and(personne, some(aEnfant, anything))), (sculpteur, and(personne, some(aCree, sculpture)))],
% Abi = [(david, sculpture), (joconde, objet), (michelAnge, personne), (sonnets, livre), (vinci, personne)],
% Abr = [(michelAnge, david, aCree), (michelAnge, sonnets, aEcrit), (vinci, joconde, aCree)].


% Astuces:
% =/2
% 'mia'= mia -> true
% '2' = 2 -> false
% structure recursive + unification

%--------------Partie II----------------
% acquisition_prop_type1:
    % * lecture de l'instance I
    % * lecture du concept/de l'expression C
    % * vérification du concept C
    % * application sur not(C), des axiomes de la Tbox traitée, jusqu'à n'avoir que des concepts atomiques
    % * mise sous forme normale négative 
    % * Abi1 = Abi + la nouvelle proposition
acquisition_prop_type1(Abi, Abi1, Tbox) :-
    nl, write('Veuillez entrer le nom de l''instance :'), nl, read(I),
    nl, write('Veuillez entrer le concept ou l''expression de cette instance :'), nl, read(C), concept(C),
    applique_Tbox(not(C), Tbox, E), nnf(E, Res), concat(Abi, [(I, Res)], Abi1),!.

% acquisition_prop_type2:
    % * lecture du premier concept C1, puis du deuxième concept C2 
    % * vérification des concepts C1 et C2 
    % * application sur not(and(C1, C2)), des axiomes de la Tbox traitée, jusqu'à n'avoir que des concepts atomiques 
    % * mise sous forme normale négative 
    % * Abi1 = Abi + la nouvelle proposition    
acquisition_prop_type2(Abi, Abi1, Tbox) :-
    nl, write('Veuillez entrer le premier concept ou expression de la proposition :'), nl, read(C1), concept(C1),
    nl, write('Veuillez entrer le deuxième concept ou expression de la proposition :'), nl, read(C2), concept(C2),
    applique_Tbox(not(and(C1, C2)), Tbox, E), nnf(E, Res), genere(I), concat(Abi, [(I, Res)], Abi1),!.

deuxieme_etape(Abi,Abi1,Tbox) :- saisie_et_traitement_prop_a_demontrer(Abi,Abi1,Tbox).

saisie_et_traitement_prop_a_demontrer(Abi,Abi1,Tbox) :- 
    nl,write('Entrez le numero du type de proposition que vous voulez demontrer :'),nl,
    write('1 Une instance donnee appartient a un concept donne.'),nl,
    write('2 Deux concepts n"ont pas d"elements en commun(ils ont une intersection vide).'),nl, 
    read(R), suite(R,Abi,Abi1,Tbox).

suite(1,Abi,Abi1,Tbox) :- acquisition_prop_type1(Abi,Abi1,Tbox),!.
suite(2,Abi,Abi1,Tbox) :- acquisition_prop_type2(Abi,Abi1,Tbox),!.
suite(_,Abi,Abi1,Tbox) :- nl,write('Cette reponse est incorrecte.'),nl,
                          saisie_et_traitement_prop_a_demontrer(Abi,Abi1,Tbox).

%--------------Partie III----------------
%Trouver les successeurs
%individu(i).
%individu(s(I)) :- individu(I)
% res => i, s(i), s(s(i))...

tri_Abox([], Lie, Lpt, Li, Lu, Ls).
tri_Abox([(I, some(R, C)) | Abi], Lie, Lpt, Li, Lu, Ls) :- rname(R), concept(C), concat(LiePartiel, [(I, some(R, C))], Lie), 
                                                           tri_Abox(Abi, LiePartiel, Lpt, Li, Lu, Ls),!.
tri_Abox([(I, all(R, C)) | Abi], Lie, Lpt, Li, Lu, Ls) :- rname(R), concept(C), concat(LptPartiel, [(I, all(R, C))], Lpt), 
                                                          tri_Abox(Abi, Lie, LptPartiel, Li, Lu, Ls),!.
tri_Abox([(I, and(C1, C2)) | Abi], Lie, Lpt, Li, Lu, Ls) :- concept(C1), concept(C2), concat(LiPartiel, [(I, and(C1, C2))], Li), 
                                                            tri_Abox(Abi, Lie, Lpt, LiPartiel, Lu, Ls),!.                                                       
tri_Abox([(I, or(C1, C2)) | Abi], Lie, Lpt, Li, Lu, Ls) :- concept(C1), concept(C2), concat(LuPartiel, [(I, or(C1, C2))], Lu), 
                                                           tri_Abox(Abi, Lie, Lpt, Li, LuPartiel, Ls),!.  
tri_Abox([(I, not(C)) | Abi], Lie, Lpt, Li, Lu, Ls) :- cnamea(C), concat(LsPartiel, [(I, not(C))], Ls), 
                                                       tri_Abox(Abi, Lie, Lpt, Li, Lu, LsPartiel),!.  
tri_Abox([(I, C) | Abi], Lie, Lpt, Li, Lu, Ls) :- cnamea(C), concat(LsPartiel, [(I, C)], Ls), 
                                                  tri_Abox(Abi, Lie, Lpt, Li, Lu, LsPartiel),!.

resolution(Lie, Lpt, Li, Lu, Ls, Abr) :- complete_some(Lie, Lpt, Li, Lu, Ls, Abr),!.

% test_clash :
    % * a:C et a:not(C) dans Ls --> clash donc stop 
    % * sinon, nouveau noeud de résolution (récursion)
test_clash(_, _, _, _, Ls, _) :- member((A, C), Ls), member((A, not(C)), Ls), nl, write('Clash'), nl,!.
test_clash(Lie, Lpt, Li, Lu, Ls, Abr) :- resolution(Lie, Lpt, Li, Lu, Ls, Abr), nl, write('Nouvelle résolution'), nl,!.

% complete_some :
    % * s'il n'y a pas d'assertion du type a:some(R, C), on traite les règles and
    % * sinon, on génère b, on ajoute <a,b>:R dans Abr et b:C dans Ls, on enlève la règle a:some(R, C) de Lie, et on teste s'il y a un clash
complete_some([], Lpt, Li, Lu, Ls, Abr) :- transformation_and([], Lpt, Li, Lu, Ls, Abr),!.
% complete_some([(A, some(R, C)) | Lie], Lpt, Li, Lu, Ls, Abr) :- genere(B), concat(Abr, [(A, B, R)], Abr1),
%                                                                 concat(Ls, [(B, C)], Ls1), enleve((A, some(R, C)), Lie, Lie1),
%                                                                 test_clash(Lie1, Lpt, Li, Lu, Ls1, Abr1),!.
complete_some([(A, some(R, C)) | Lie], Lpt, Li, Lu, Ls, Abr) :- genere(B), concat(Abr, [(A, B, R)], Abr1),
                                                                evolue((B, C), Lie, Lpt, Li, Lu, Ls, _, _, _, _, Ls1),
                                                                enleve((A, some(R, C)), Lie, Lie1),
                                                                affiche_evolution_Abox(Ls, [(A, some(R, C)) | Lie], Lpt, Li, Lu, Abr, Ls1, Lie1, Lpt, Li, Lu, Abr1),
                                                                test_clash(Lie1, Lpt, Li, Lu, Ls1, Abr1),!.

% transformation_and :
%     * s'il n'y a pas d'assertion du type a:and(C, D), on traite les règles all
%     * sinon, on ajoute a:C et a:D dans Ls, on enlève la règle a:and(C, D), et on teste s'il y a un clash
transformation_and(Lie, Lpt, [], Lu, Ls, Abr) :- deduction_all(Lie, Lpt, [], Lu, Ls, Abr),!.
% transformation_and(Lie, Lpt, [(A, and(C, D)) | Li], Lu, Ls, Abr) :- concat(Ls, [(A, C), (A, D)], Ls1),
%                                                                     enleve((A, and(C, D)), Li, Li1),
%                                                                     test_clash(Lie, Lpt, Li1, Lu, Ls1, Abr),!.
transformation_and(Lie, Lpt, [(A, and(C, D)) | Li], Lu, Ls, Abr) :- evolue((A, C), Lie, Lpt, Li, Lu, Ls, _, _, _, _, Ls1),
                                                                    evolue((A, D), Lie, Lpt, Li, Lu, Ls1, _, _, _, _, Ls2),
                                                                    enleve((A, and(C, D)), Li, Li1),
                                                                    affiche_evolution_Abox(Ls, Lie, Lpt, [(A, and(C, D)) | Li], Lu, Abr, Ls2, Lie, Lpt, Li1, Lu, Abr),
                                                                    test_clash(Lie, Lpt, Li1, Lu, Ls2, Abr),!.

% deduction_all :
%     * s'il n'y a pas d'assertion du type a:all(R, C), on traite les règles or
%     * sinon, on cherche tous les b tels que a:all(R, C) est dans Lpt et <a,b>:R est dans Abr, on ajoute b:C dans Ls,
%     on enlève la règle a:all(R, C), et on teste s'il y a un clash
deduction_all(Lie, [], Li, Lu, Ls, Abr) :- transformation_or(Lie, [], Li, Lu, Ls, Abr),!.
% deduction_all(Lie, Lpt, Li, Lu, Ls, Abr) :- member((A, all(R, C)), Lpt), member((A, B, R), Abr), concat(Ls, [(B, C)], Ls1),
%                                             enleve((A, all(R, C)), Lpt, Lpt1), test_clash(Lie, Lpt1, Li, Lu, Ls1, Abr).
deduction_all(Lie, Lpt, Li, Lu, Ls, Abr) :- member((A, all(R, C)), Lpt), member((A, B, R), Abr), 
                                            evolue((B, C), Lie, Lpt, Li, Lu, Ls, _, _, _, _, Ls1),
                                            enleve((A, all(R, C)), Lpt, Lpt1),
                                            affiche_evolution_Abox(Ls, Lie, Lpt, Li, Lu, Abr, Ls1, Lie, Lpt1, Li, Lu, Abr),
                                            test_clash(Lie, Lpt1, Li, Lu, Ls1, Abr).


% transformation_or :
%     * s'il n'y a pas d'assertion du type a:or(R, C) (et qu'il n'y a pas eu de clash depuis), il y a donc erreur de résolution
%     * sinon, dans un noeud de résolution, on ajoute a:C dans Ls et on teste s'il y a un clash, 
%     et dans un autre noeud, on ajoute a:D et on teste s'il y a un clash. Dans les 2 cas, il faut enlever la règle a:or(C, D)
% transformation_or(Lie, Lpt, Li, [(A, or(C, D)) | Lu], Ls, Abr) :- concat(Ls, [(A, C)], Ls1), concat(Ls, [(A, D)], Ls2),
%                                                                   enleve((A, or(C, D)), Lu, Lu1),
%                                                                   test_clash(Lie, Lpt, Li, Lu1, Ls1, Abr),
%                                                                   test_clash(Lie, Lpt, Li, Lu1, Ls2, Abr),!.
transformation_or(Lie, Lpt, Li, [(A, or(C, D)) | Lu], Ls, Abr) :- enleve((A, or(C, D)), Lu, Lu1),
                                                                  evolue((A, C), Lie, Lpt, Li, Lu, Ls, _, _, _, _, Ls1),
                                                                  affiche_evolution_Abox(Ls, Lie, Lpt, Li, [(A, or(C, D)) | Lu], Abr, Ls1, Lie, Lpt, Li, Lu1, Abr),
                                                                  test_clash(Lie, Lpt, Li, Lu1, Ls1, Abr),
                                                                  evolue((A, D), Lie, Lpt, Li, Lu, Ls, _, _, _, _, Ls2),
                                                                  affiche_evolution_Abox(Ls, Lie, Lpt, Li, [(A, or(C, D)) | Lu], Abr, Ls2, Lie, Lpt, Li, Lu1, Abr),
                                                                  test_clash(Lie, Lpt, Li, Lu1, Ls2, Abr),!.


evolue((A, some(R, C)), Lie, Lpt, Li, Lu, Ls, Lie1, Lpt, Li, Lu, Ls) :- concat(Lie, [(A, some(R, C))], Lie1),!.
evolue((A, and(C, D)), Lie, Lpt, Li, Lu, Ls, Lie, Lpt, Li1, Lu, Ls) :- concat(Li, [(A, and(C, D))], Li1),!.
evolue((A, all(R, C)), Lie, Lpt, Li, Lu, Ls, Lie, Lpt1, Li, Lu, Ls) :- concat(Lpt, [(A, all(R, C))], Lpt1),!.
evolue((A, or(C, D)), Lie, Lpt, Li, Lu, Ls, Lie, Lpt, Li, Lu1, Ls) :- concat(Lu, [(A, or(C, D))], Lu1),!.
evolue((A, C), Lie, Lpt, Li, Lu, Ls, Lie, Lpt, Li, Lu, Ls1) :- concat(Ls, [(A, C)], Ls1),!.
evolue((A, not(C)), Lie, Lpt, Li, Lu, Ls, Lie, Lpt, Li, Lu, Ls1) :- concat(Ls, [(A, not(C))], Ls1),!.

affiche_lst_inst([]).
affiche_lst_inst([(A, E) | L]) :- write(A), write(':'), affiche_expr(E), nl, affiche_lst_inst(L),!.
affiche_lst_inst([(A, B, R) | L]) :- write(A), write(','), write(B), write(':'), write(R), nl, affiche_lst_inst(L),!.

affiche_expr(C) :- cnamea(C), write(C),!.
affiche_expr(not(C)) :- cnamea(C), write('¬'), write(C),!.
affiche_expr(some(R, C)) :- write('∃'), write(R), write('.'), affiche_expr(C),!.
affiche_expr(all(R, C)) :- write('∀'), write(R), write('.'), affiche_expr(C),!.
affiche_expr(and(C, D)) :- affiche_expr(C), write('⊓'), affiche_expr(D),!.
affiche_expr(or(C, D)) :- affiche_expr(C), write('⊔'), affiche_expr(D),!.


affiche_evolution_Abox(Ls1, Lie1, Lpt1, Li1, Lu1, Abr1, Ls2, Lie2, Lpt2, Li2, Lu2, Abr2) :-
    nl, write('Ancienne Abox'), nl, affiche_lst_inst(Ls1), affiche_lst_inst(Lie1), affiche_lst_inst(Lpt1), affiche_lst_inst(Li1), affiche_lst_inst(Lu1), affiche_lst_inst(Abr1),
    nl, write('Nouvelle Abox'), nl, affiche_lst_inst(Ls2), affiche_lst_inst(Lie2), affiche_lst_inst(Lpt2), affiche_lst_inst(Li2), affiche_lst_inst(Lu2), affiche_lst_inst(Abr2),!.


troisieme_etape(Abi,Abr) :- tri_Abox(Abi,Lie,Lpt,Li,Lu,Ls),
                            resolution(Lie,Lpt,Li,Lu,Ls,Abr),
                            nl,write('Youpiiiiii, on a demontre la
                            proposition initiale !!!').


%-----------------MAIN--------------------------
programme :- premiere_etape(Tbox,Abi,Abr),
             deuxieme_etape(Abi,Abi1,Tbox),
             troisieme_etape(Abi1,Abr).
