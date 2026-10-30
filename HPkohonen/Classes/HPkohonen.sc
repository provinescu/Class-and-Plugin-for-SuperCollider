HPkohonen3 : UGen {
    *ar { |rate=10, data1=0, data2=0, data3=0, learningRate=0.01, distanceNeighbourhood=8, gate=1|
        ^this.multiNew('audio', rate, data1, data2, data3, learningRate, distanceNeighbourhood, gate)
    }
    *kr { |rate=10, data1=0, data2=0, data3=0, learningRate=0.01, distanceNeighbourhood=8, gate=1|
        ^this.multiNew('control', rate, data1, data2, data3, learningRate, distanceNeighbourhood, gate)
    }
}

HPkohonen1 : UGen {
    *ar { |rate=10, data1=0, learningRate=0.01, distanceNeighbourhood=16, gate=1|
        ^this.multiNew('audio', rate, data1, learningRate, distanceNeighbourhood, gate)
    }
    *kr { |rate=10, data1=0, learningRate=0.01, distanceNeighbourhood=16, gate=1|
        ^this.multiNew('control', rate, data1, learningRate, distanceNeighbourhood, gate)
    }
}
