/*
HPNeuralNetActivations - exemple corrigé
Prérequis : plugin et classe corrigée installés.
Exécutez les blocs dans l’ordre avec Cmd+Entrée.
*/

// Vérification
HPNeuralNetActivations.dumpInterface;
HPNeuralNetActivationsBuffer;

// EXEMPLE 3 - APPRENDRE UNE FOIS PAR ATTAQUE AUDIO
// ============================================================

// 3A. Creation
(
var hiddenLayers = [8];
var activations = [\tanh, \sigmoid];

s.waitForBoot {
    ~onsetWeights.notNil.if { ~onsetWeights.free };
    ~onsetNetwork.notNil.if { ~onsetNetwork.free };
    OSCdef(\onsetMonitor).notNil.if { OSCdef(\onsetMonitor).free };

    ~onsetWeights = HPNeuralNetActivationsBuffer.alloc(
        s, 1, hiddenLayers, 1
    );
    s.sync;

    SynthDef(\hpLearnOnOnsetCorrected, {
        |weightsBuf = 0,
         learningEnabled = 0,
         target = 0.5,
         learning = 0.01,
         onsetThreshold = 0.5,
         inputGain = 1|

        var input;
        var amplitude;
        var chain;
        var onset;
        var trainTrigger;
        var neuralOutput;

        input = SoundIn.ar(0) * inputGain;
        amplitude = Amplitude.kr(input, 0.01, 0.15)
            .linlin(0, 0.5, 0, 1)
            .clip(0, 1);

        chain = FFT(LocalBuf(1024), input);
        onset = Onsets.kr(chain, onsetThreshold);
        trainTrigger = onset * learningEnabled;

        neuralOutput = HPNeuralNetActivations.kr(
            inputs: [amplitude],
            hiddenLayers: hiddenLayers,
            numOutputs: 1,
            activations: activations,
            targets: [target],
            learning: learning,
            temperature: 1,
            trainTrig: trainTrigger,
            resetTrig: 0,
            seed: 888,
            weightsBuf: weightsBuf,
            loadTrig: 0,
            saveTrig: 0
        );

        SendReply.kr(
            Impulse.kr(5),
            '/hpOnsetLearnCorrected',
            [amplitude, neuralOutput, trainTrigger]
        );
    }).add;

    s.sync;

    OSCdef(\onsetMonitor, { |message|
        [
            \amplitude, message[3],
            \sortie, message[4],
            \attaque, message[5]
        ].postln;
    }, '/hpOnsetLearnCorrected');

    ~onsetNetwork = Synth(
        \hpLearnOnOnsetCorrected,
        [\weightsBuf, ~onsetWeights.buffer.bufnum]
    );
};
)

// 3B. Activer l'apprentissage sur les attaques
~onsetNetwork.set(\target, 0.8, \learningEnabled, 1);

// 3C. Suspendre l'apprentissage
~onsetNetwork.set(\learningEnabled, 0);

// 3D. Ajuster la sensibilite de detection
~onsetNetwork.set(\onsetThreshold, 0.3);

// 3E. Nettoyage
(
~onsetNetwork.notNil.if { ~onsetNetwork.free };
~onsetWeights.notNil.if { ~onsetWeights.free };
OSCdef(\onsetMonitor).notNil.if { OSCdef(\onsetMonitor).free };
)
