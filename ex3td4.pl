equiv(attiranceExcHomme, all(amant,homme)).
equiv(femmeHetero, and(femme,attiranceExcHomme)).
equiv(femme,not(homme)).
equiv(travesti, and(not(femme),habilleEnFemme)).

cnamea(homme).
cnamea(habilleEnFemme).

cnamena(attiranceExcHomme).
cnamena(femmeHetero).
cnamena(femme).
cnamena(travesti).

iname(eli).
iname(eon).

rname(amant).


inst(eli,femmeHetero).
inst(eon,habilleEnFemme).

instR(eli,eon,amant).


% ?- premiere_etape(Tbox,Abi,Abr).
% Tbox = [(attiranceExcHomme, all(amant, homme)), (femme, not(homme)), (femmeHetero, and(not(homme), all(amant, homme))), (travesti, and(homme, habilleEnFemme))],
% Abi = [(eli, and(not(homme), all(amant, homme))), (eon, habilleEnFemme)],
% Abr = [(eli, eon, amant)].