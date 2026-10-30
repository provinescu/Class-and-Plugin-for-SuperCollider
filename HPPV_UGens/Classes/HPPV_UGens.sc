PV_HPshiftDown : PV_ChainUGen {
    *new { |chain, shift = 0| ^this.multiNew('control', chain, shift) }
}

PV_HPecartType : PV_ChainUGen {
    *new { |chain, multiplier = 1| ^this.multiNew('control', chain, multiplier) }
}

PV_HPinverse : PV_ChainUGen {
    *new { |chain, index = 1| ^this.multiNew('control', chain, index) }
}

PV_HPfiltre : PV_ChainUGen {
    *new { |chain, index = 0, size = 1| ^this.multiNew('control', chain, index, size) }
}
