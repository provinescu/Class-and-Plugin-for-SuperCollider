HPclassFractal3D {

var nombreTransformations, transformations, outF, outA, outD, inF, inA, inD;

*new {arg nt, x, y, z;
^super.new.init(nt, x, y, z);
}

init {arg nt, x, y, z;
if(x == nil, {x=1.0.rand2});inF=x;
if(y == nil, {y=1.0.rand2});inA=y;
if(z == nil, {z=1.0.rand2});inD=z;
if(nt == nil, {nombreTransformations=6},
	{if(nt > 100, {nombreTransformations=100},{if(nt < 1, {nombreTransformations=1})})});
transformations=[];
100.do({arg i; var tt=[];
12.do({tt=tt.add(1.0.rand - 0.5)});
while({tt.sum.abs > 1.0},{tt=[];12.do({tt=tt.add(1.0.rand - 0.5)})});
transformations=transformations.add(tt);
});
// Calcule les 256 premieres valeurs
256.do({var n, tt, xt, yt, zt;
n=rrand(1, nombreTransformations);
tt=transformations.at(n - 1);
xt=tt.at(0) * inF + tt.at(1) * inA + tt.at(2) * inD + tt.at(3);
yt=tt.at(4) * inF + tt.at(5) * inA + tt.at(6) * inD + tt.at(7);
zt=tt.at(8) * inF + tt.at(9) * inA + tt.at(10) * inD + tt.at(11);
inF=xt;inA=yt;inD=zt;// valeurs fractals
});
}
// Fractalnext {arg nt, x, y, z; var n, tt, xt, yt, zt;
// Init new condition initial ?!?!
if(x != nil, {if(x > 1, {x=1},{if(x < -1, {x= (-1)})});inF=x});
if(y != nil, {if(y > 1, {y=1},{if(y < -1, {y= (-1)})});inF=y});
if(z != nil, {if(z > 1, {z=1},{if(z < -1, {z= (-1)})});inF=z});
if(nt != nil, {if(nt > 100, {nt=100},{if(nt < 1, {nt=1})});nombreTransformations=nt});

// Fractal
n=rrand(1, nombreTransformations);
tt=transformations.at(n - 1);
xt=tt.at(0) * inF + tt.at(1) * inA + tt.at(2) * inD + tt.at(3);
yt=tt.at(4) * inF + tt.at(5) * inA + tt.at(6) * inD + tt.at(7);
zt=tt.at(8) * inF + tt.at(9) * inA + tt.at(10) * inD + tt.at(11);
inF=xt;inA=yt;inD=zt;// valeurs fractals
^[inF, inA, inD];// Sortie fractal}}