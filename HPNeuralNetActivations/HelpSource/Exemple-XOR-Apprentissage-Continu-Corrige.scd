/*
HPNeuralNetActivations - exemple corrigé
Prérequis : plugin et classe corrigée installés.
Exécutez les blocs dans l’ordre avec Cmd+Entrée.
*/

// Vérification
HPNeuralNetActivations.dumpInterface;
HPNeuralNetActivationsBuffer;

// EXEMPLE 1 - XOR AVEC APPRENTISSAGE AUTOMATIQUE CORRIGE
// ============================================================

// 1A. Creation
(
var hiddenLayers = [8, 6];
var activations = [\relu, \tanh, \sigmoid];

s.waitForBoot {
    ~xorWeights.notNil.if { ~xorWeights.free };
    ~xor.notNil.if { ~xor.free };
    OSCdef(\xorMonitor).notNil.if { OSCdef(\xorMonitor).free };

    ~xorWeights = HPNeuralNetActivationsBuffer.alloc(
        s, 2, hiddenLayers, 1
    );
    s.sync;

    SynthDef(\hpXORContinuousCorrected, {
        |weightsBuf = 0,
         input0 = 0,
         input1 = 0,
         target = 0,
         learning = 0.02,
         learningEnabled = 0,
         learningRate = 10,
         manualTrain = 0,
         resetTrig = 0,
         saveTrig = 0,
         loadTrig = 0|

        var automaticTrain;
        var trainTrigger;
        var neuralOutput;

        // Dust produit une impulsion d'un seul bloc de controle.
        automaticTrain = Dust.kr(
            learningRate.max(0.1)
        ) * learningEnabled;

        trainTrigger = (automaticTrain + manualTrain).clip(0, 1);

        neuralOutput = HPNeuralNetActivations.kr(
            inputs: [input0, input1],
            hiddenLayers: hiddenLayers,
            numOutputs: 1,
            activations: activations,
            targets: [target],
            learning: learning,
            temperature: 1,
            trainTrig: trainTrigger,
            resetTrig: resetTrig,
            seed: 1234,
            weightsBuf: weightsBuf,
            loadTrig: loadTrig,
            saveTrig: saveTrig
        );

        SendReply.kr(
            Impulse.kr(4),
            '/hpXORContinuousCorrected',
            [input0, input1, target, neuralOutput]
        );
    }).add;

    s.sync;

    OSCdef(\xorMonitor, { |message|
        (
            "XOR [" ++ message[3].round(0.001)
            ++ ", " ++ message[4].round(0.001)
            ++ "] cible: " ++ message[5].round(0.001)
            ++ " sortie: " ++ message[6].round(0.001)
        ).postln;
    }, '/hpXORContinuousCorrected');

    ~xor = Synth(\hpXORContinuousCorrected, [
        \weightsBuf, ~xorWeights.buffer.bufnum
    ]);

    "XOR cree. Executez ensuite le bloc 1B.".postln;
};
)

// 1B. Apprentissage automatique des QUATRE exemples XOR
(
~xorTraining.notNil.if { ~xorTraining.stop };

~xorData = [
    [0, 0, 0],
    [0, 1, 1],
    [1, 0, 1],
    [1, 1, 0]
];

~xorTraining = Routine {
    1000.do { |epoch|
        ~xorData.scramble.do { |example|
            ~xor.set(
                \learningEnabled, 0,
                \input0, example[0],
                \input1, example[1],
                \target, example[2],
                \manualTrain, 0
            );

            0.01.wait;
            ~xor.set(\manualTrain, 1);
            0.01.wait;
            ~xor.set(\manualTrain, 0);
        };

        if((epoch % 100) == 0) {
            ("XOR epoch " ++ epoch).postln;
        };
    };

    "Apprentissage XOR termine.".postln;
}.play(AppClock);
)

// 1C. Tester les quatre cas
(
~xorTest.notNil.if { ~xorTest.stop };

~xorTest = Routine {
    ~xor.set(\learningEnabled, 0, \manualTrain, 0);

    ~xorData.do { |example|
        ~xor.set(
            \input0, example[0],
            \input1, example[1],
            \target, example[2]
        );
        1.5.wait;
    };
}.play(AppClock);
)

// 1D. Nettoyage XOR
(
~xorTraining.notNil.if { ~xorTraining.stop };
~xorTest.notNil.if { ~xorTest.stop };
~xor.notNil.if { ~xor.free };
~xorWeights.notNil.if { ~xorWeights.free };
OSCdef(\xorMonitor).notNil.if { OSCdef(\xorMonitor).free };
)


// ============================================================
