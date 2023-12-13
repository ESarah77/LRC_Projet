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
concept(X) :- setof(Y,cnamea(Y),L),member(X,L).
concept(X) :- setof(Y,cnamena(Y),L),member(X,L).

% ; pour "ou"

% autoref().

% à gauche = concept non atomique, à droite = expression/concept générique
% si à droite, il n'y a que des concepts atomiques, on sait que c'est impossible qu'il soit à droite donc pas-autoref
pas-autoref(_, and(C1, C2), _) :- setof(X, cnamea(X), L), member(C1, L), member(C2, L).
pas-autoref(_, or(C1, C2), _) :- setof(X, cnamea(X), L), member(C1, L), member(C2, L).
pas-autoref(_, some(R, C), _) :- setof(X, rname(X), Lr), member(R, Lr), setof(Y, cnamea(Y), Lc), member(C, Lc).
pas-autoref(_, all(R, C), _) :- setof(X, rname(X), Lr), member(R, Lr), setof(Y, cnamea(Y), Lc), member(C, Lc).
% traitement où on doit appliquer d'autres définitions pour définir les concepts non atomiques
% autres paramètres ??

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

