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
concept(X) :- cnamea(X).
concept(X) :- cnamena(X).
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
pas-autoref(_, C1) :- cnamea(C1).
pas-autoref(C, C1) :- cnamena(C1), C \= C1, equiv(C1, E), pas-autoref(C, E).
pas-autoref(C, not(E)) :- pas-autoref(C, E).
pas-autoref(C, and(C1, C2)) :- pas-autoref(C, C1), pas-autoref(C, C2).
pas-autoref(C, or(C1, C2)) :- pas-autoref(C, C1), pas-autoref(C, C2).
pas-autoref(C, some(R, C1)) :- rname(R), pas-autoref(C, C1).
pas-autoref(C, all(R, C1)) :- rname(R), pas-autoref(C, C1).

% autoref : il s'agit de la négation de pas-autoref
autoref(C, E) :- not(pas-autoref(C, E)).

% Mettre sous forme normale negative
% traitement-Tbox(Cx) :- concept-atomique(Cx); traitement-Tbox(Cx-qqch).

% Deploiement de TBox
% traitement-ABox(Ix).

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

