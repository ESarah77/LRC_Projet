%--------Utilitaires fournis-----------
concat([],L1,L1).
concat([X|Y],L1,[X|L2]) :- concat(Y,L1,L2).

enleve(X,[X|L],L) :-!.
enleve(X,[Y|L],[Y|L2]) :- enleve(X,L,L2).

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
pas-autoref(_, C1) :- cnamea(C1),!.
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

% applique_nnf(Lce, Lpartiel, Lfinal) : appel nnf sur tous les E des éléments de Lce, qui sont des couples (X,E),
% et ajoute le résultat courant dans la liste des résultats précédents
applique_nnf([], L, L).
applique_nnf([(X, E) | L], ResPartiel, ResFinal) :- nnf(E, Ennf), concat(ResPartiel, [(X, Ennf)], Res),
                                                    applique_nnf(L, Res, ResFinal),!.

% Tbox = résultat = [(CNA1, E1), (CNA2, E2), ...]
% traitement_Tbox : 
    % * récupère les concepts non atomiques
    % * pour chaque concept, applique sa définition et d'autres jusqu'à n'avoir que des concepts atomiques
    % * met chaque expression sous forme normale négative 
traitement_Tbox(Tbox) :- setof(C, cnamena(C), L), applique_def_Tbox(L, [], Ldef), applique_nnf(Ldef, [], Tbox),!.

% Deploiement de TBox
% traitement-ABox(Ix).

% applique_def_Abox(Lic, Lpartiel, Lfinal) : appel applique_def sur tous les concepts C de la liste Lic,
% où les éléments sont de la forme (I, C), et ajoute le résultat courant dans la liste des résultats précédents
applique_def_Abox([], L, L).
applique_def_Abox([(I, C) | L], ResPartiel, ResFinal) :- applique_def(C, CRes), concat(ResPartiel, [(I, CRes)], Res),
                                                         applique_def_Abox(L, Res, ResFinal),!.

% traitement_Abox :
    % - Abi : liste contenant les assertions de concept
    %     * récupère les assertions de concept sous la forme de couple (I, C)
    %     * pour chaque concept, applique sa définition et d'autres jusqu'à n'avoir que des concepts atomiques
    %     * met chaque expression sous forme normale négative
    % - Abr : liste contenant les assertions de rôles
    %     * récupère les assertions de concept sous la forme de tuple (A, B, R) 
traitement_Abox(Abi, Abr) :- setof((I, C), inst(I, C), L), applique_def_Abox(L, [], Ldef), applique_nnf(Ldef, [], Abi),
                             setof((A, B, R), instR(A, B, R), Abr),!.

premiere_etape(Tbox, Abi, Abr) :- traitement_Tbox(Tbox), traitement_Abox(Abi, Abr),!.

% Astuces:
% =/2
% 'mia'= mia -> true
% '2' = 2 -> false
% structure recursive + unification

%--------------Partie II----------------

%--------------Partie III----------------
%Trouver les successeurs
%individu(i).
%individu(s(I)) :- individu(I)
% res => i, s(i), s(s(i))...

