HPchaos : UGen { *ar { |freq=10, chaos=3.9, seed=0.5| ^this.multiNew('audio', freq, chaos, seed) } *kr { |freq=10, chaos=3.9, seed=0.5| ^this.multiNew('control', freq, chaos, seed) } }
HPneurones : UGen { *ar { |freq=10, input=0, target=0, mode=0, learning=0.01, temperature=1, neurons=8| ^this.multiNew('audio', freq,input,target,mode,learning,temperature,neurons) } }
HPgenetiques : UGen { *ar { |freq=10,input=0,crossover=0.5,mutation=0.1,individuals=16,mode=0| ^this.multiNew('audio',freq,input,crossover,mutation,individuals,mode) } }
HPneurones3D : MultiOutUGen { *kr { |freq=10,inF=0,inA=0,inD=0,outF=0,outA=0,outD=0,mode=0,learning=0.01,temperature=1,neurons=12| ^this.multiNew('control',3,freq,inF,inA,inD,outF,outA,outD,mode,learning,temperature,neurons) } init { |n ... ins| inputs=ins; ^this.initOutputs(n,rate) } }
HPgenetiques3D : MultiOutUGen { *kr { |freq=10,inF=0,inA=0,inD=0,crossover=0.5,mutation=0.1,individuals=16,mode=0| ^this.multiNew('control',3,freq,inF,inA,inD,crossover,mutation,individuals,mode) } init { |n ... ins| inputs=ins; ^this.initOutputs(n,rate) } }
HPprobability1 : UGen { *ar { |freq=10,input=0,size=16| ^this.multiNew('audio',freq,input,size) } }
HPprobability2 : UGen { *ar { |freq=10,input=0,size=16| ^this.multiNew('audio',freq,input,size) } }
HPfractal3D : MultiOutUGen { *kr { |freq=10,inF=0,inA=0,inD=0,transforms=10,mode=0| ^this.multiNew('control',3,freq,inF,inA,inD,transforms,mode) } init { |n ... ins| inputs=ins; ^this.initOutputs(n,rate) } }
HPfftShift : UGen { *ar { |input=0,index=0| ^this.multiNew('audio',input,index) } }
HPfftDiff : UGen { *ar { |in1=0,in2=0| ^this.multiNew('audio',in1,in2) } }
HPfftRand : UGen { *ar { |in1=0,in2=0| ^this.multiNew('audio',in1,in2) } }
HPfftLog : UGen { *ar { |input=0| ^this.multiNew('audio',input) } }
