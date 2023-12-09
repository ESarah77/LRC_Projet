:- [dmt]. 
%charger/compilier tout d'abord le demonstrateur, ensuite les faits dans le fichier courant

%TBox
%definitions
equiv(sculpteur,and(personne,some(aCree,sculpture))).
equiv(auteur,and(personne,some(aEcrit,livre))).
equiv(editeur,and(personne,and(not(some(aEcrit,livre)),some(aEdite,livre)))).
equiv(parent,and(personne,some(aEnfant,anything))).

%concepts atomiques
cnamea(personne).
cnamea(livre).
cnamea(objet).
cnamea(sculpture).
cnamea(anything).
cnamea(nothing).

%concepts non atomiques
cnamena(auteur).
cnamena(editeur).
cnamena(sculpteur).
cnamena(parent).

%instances
iname(michelAnge).
iname(david).
iname(sonnets).
iname(vinci).
iname(joconde).

%rôles
rname(aCree).
rname(aEcrit).
rname(aEdite).
rname(aEnfant).

%ABox
%instantiations des concepts
inst(michelAnge,personne).
inst(david,sculpture).
inst(sonnets,livre).
inst(vinci,personne).
inst(joconde,objet).

%instantiations des rôles
instR(michelAnge, david, aCree).
instR(michelAnge, sonnets, aEcrit).
instR(vinci, joconde, aCree).