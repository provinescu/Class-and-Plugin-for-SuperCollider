HPNeuralNetActivations : MultiOutUGen {
    classvar <>activationNames = #[sigmoid, tanh, relu, leakyRelu, linear, softsign];

    *activationCode { |item|
        ^activationNames.indexOf(item.asSymbol) ? 0
    }

    *parameterCount { |numInputs = 3, hiddenLayers = #[9], numOutputs = 3|
        var sizes = [numInputs] ++ hiddenLayers.asArray ++ [numOutputs];
        var weights = 0;

        (sizes.size - 1).do { |index|
            weights = weights + (sizes[index] * sizes[index + 1]);
        };

        ^weights + hiddenLayers.sum + numOutputs
    }

    *kr {
        |inputs = #[0, 0, 0], hiddenLayers = #[9], numOutputs = 3,
        activations = #[sigmoid, sigmoid], targets, learning = 0.05,
        temperature = 1, trainTrig = 0, resetTrig = 0, seed = 1979,
        weightsBuf = -1, loadTrig = 0, saveTrig = 0|

        var hiddenSizes = hiddenLayers.asArray;
        var activationCodes;
        var arguments;

        inputs = inputs.asArray;

        if(hiddenSizes.size < 1 or: { hiddenSizes.size > 8 }) {
            Error("HPNeuralNetActivations: 1 a 8 couches cachees requises.").throw;
        };

        if(inputs.size < 1 or: { inputs.size > 32 }) {
            Error("HPNeuralNetActivations: 1 a 32 entrees requises.").throw;
        };

        if(numOutputs < 1 or: { numOutputs > 32 }) {
            Error("HPNeuralNetActivations: 1 a 32 sorties requises.").throw;
        };

        if(hiddenSizes.any { |size| size < 1 or: { size > 128 } }) {
            Error("HPNeuralNetActivations: 1 a 128 neurones par couche.").throw;
        };

        activationCodes = activations.asArray
            .extend(hiddenSizes.size + 1, \sigmoid)
            .keep(hiddenSizes.size + 1)
            .collect { |activation| this.activationCode(activation) }
            .extend(9, 0)
            .keep(9);

        targets = (targets ? Array.fill(numOutputs, 0))
            .asArray
            .extend(numOutputs, 0)
            .keep(numOutputs);

        hiddenSizes = hiddenSizes.extend(8, 1).keep(8);

        arguments = [
            'control',
            numOutputs,
            inputs.size,
            numOutputs,
            hiddenLayers.size
        ]
        ++ hiddenSizes
        ++ activationCodes
        ++ inputs
        ++ targets
        ++ [
            learning,
            temperature,
            trainTrig,
            resetTrig,
            seed,
            weightsBuf,
            loadTrig,
            saveTrig
        ];

        ^this.multiNewList(arguments)
    }

    init { |numOutputs ... theInputs|
        inputs = theInputs;
        ^this.initOutputs(numOutputs, rate)
    }
}

HPNeuralNetActivationsBuffer {
    var <buffer;

    *alloc { |server, numInputs = 3, hiddenLayers = #[9], numOutputs = 3|
        ^super.new.init(
            server ? Server.default,
            numInputs,
            hiddenLayers,
            numOutputs
        )
    }

    init { |server, numInputs, hiddenLayers, numOutputs|
        buffer = Buffer.alloc(
            server,
            HPNeuralNetActivations.parameterCount(
                numInputs,
                hiddenLayers,
                numOutputs
            ),
            1
        );
        ^this
    }

    saveToDisk { |path, completionMessage|
        buffer.write(
            path.standardizePath,
            "AIFF",
            "float",
            0,
            0,
            false,
            completionMessage
        );
        ^this
    }

    free {
        buffer.free;
        ^this
    }
}
