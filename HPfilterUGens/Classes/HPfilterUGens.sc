HPdelayN : UGen {
 *ar { |in=0, maxdelaytime=0.2, delaytime=0.2| ^this.multiNew('audio', in, maxdelaytime, delaytime) }
}
HPcombC : UGen {
 *ar { |in=0, maxdelaytime=0.2, delaytime=0.2, decaytime=1| ^this.multiNew('audio', in, maxdelaytime, delaytime, decaytime) }
}
