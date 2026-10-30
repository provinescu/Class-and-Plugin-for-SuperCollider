/*
HPNeuralNetActivations - exemple corrigé
Prérequis : plugin et classe corrigée installés.
Exécutez les blocs dans l’ordre avec Cmd+Entrée.
*/

// Vérification
HPNeuralNetActivations.dumpInterface;
HPNeuralNetActivationsBuffer;

// EXEMPLE 2 - ENTREE AUDIO ET APPRENTISSAGE CONTINU CORRIGE
// ============================================================

// Utilisez un casque pour eviter le Larsen.

// 2A. Creation
(
var hiddenLayers = [12, 8];
var activations = [\relu, \tanh, \sigmoid];
var inputChannel = 0;

s.waitForBoot {
    ~audioWeights.notNil.if { ~audioWeights.free };
    ~audioNeural.notNil.if { ~audioNeural.free };
    OSCdef(\audioMonitor).notNil.if { OSCdef(\audioMonitor).free };

    ~audioWeights = HPNeuralNetActivationsBuffer.alloc(
        s, 3, hiddenLayers, 3
    );
    s.sync;

    SynthDef(\hpAudioContinuousCorrected, {
        |inputChannel = 0,
         weightsBuf = 0,
         targetFilter = 0.5,
         targetPan = 0.5,
         targetEffect = 0.2,
         learning = 0.01,
         learningEnabled = 0,
         learningRate = 10,
         learnThreshold = 0.03,
         learnOnlyWithPitch = 0,
         resetTrig = 0,
         saveTrig = 0,
         loadTrig = 0,
         inputGain = 1,
         outputAmp = 0.1,
         monitorRate = 5|

        var input;
        var amplitude;
        var pitch;
        var hasPitch;
        var brightness;
        var features;
        var validSound;
        var validPitch;
        var trainTrigger;
        var neuralOutput;
        var cutoff;
        var pan;
        var wet;
        var processed;

        input = SoundIn.ar(inputChannel) * inputGain;

        amplitude = Amplitude.kr(input, 0.01, 0.15)
            .linlin(0, 0.5, 0, 1)
            .clip(0, 1);

        # pitch, hasPitch = Pitch.kr(
            input,
            initFreq: 220,
            minFreq: 50,
            maxFreq: 4000,
            execFreq: 100,
            median: 7,
            ampThreshold: 0.01
        );

        pitch = pitch.clip(50, 4000)
            .explin(50, 4000, 0, 1);

        pitch = Select.kr(
            hasPitch > 0,
            [0, pitch]
        );

        // ZeroCrossing est deja un UGen de controle dans SuperCollider.
        brightness = ZeroCrossing.ar(input);
        brightness = A2K.kr(brightness);
        brightness = brightness
            .linlin(0, 8000, 0, 1)
            .clip(0, 1);
        brightness = Lag.kr(brightness, 0.05);

        features = [amplitude, pitch, brightness];

        validSound = amplitude > learnThreshold;
        validPitch = Select.kr(
            learnOnlyWithPitch > 0,
            [1, hasPitch > 0]
        );

        // Impulsions automatiques d'un seul bloc de controle.
        trainTrigger = Dust.kr(
            learningRate.max(0.1)
        ) * learningEnabled * validSound * validPitch;

        neuralOutput = HPNeuralNetActivations.kr(
            inputs: features,
            hiddenLayers: hiddenLayers,
            numOutputs: 3,
            activations: activations,
            targets: [targetFilter, targetPan, targetEffect],
            learning: learning,
            temperature: 1,
            trainTrig: trainTrigger,
            resetTrig: resetTrig,
            seed: 4321,
            weightsBuf: weightsBuf,
            loadTrig: loadTrig,
            saveTrig: saveTrig
        );

        cutoff = neuralOutput[0].linexp(0, 1, 120, 12000);
        pan = neuralOutput[1].linlin(0, 1, -1, 1);
        wet = neuralOutput[2].clip(0, 1);

        processed = FreeVerb.ar(
            RLPF.ar(input, cutoff, 0.2),
            wet,
            0.75,
            0.4
        );

        Out.ar(
            0,
            Limiter.ar(
                Pan2.ar(processed, pan, outputAmp),
                0.9
            )
        );

        SendReply.kr(
            Impulse.kr(monitorRate.max(0.1)),
            '/hpAudioContinuousCorrected',
            features ++ neuralOutput ++ [learningEnabled, validSound]
        );
    }).add;

    s.sync;

    OSCdef(\audioMonitor, { |message|
        (
            "analyse [amp: " ++ message[3].round(0.001)
            ++ ", hauteur: " ++ message[4].round(0.001)
            ++ ", brillance: " ++ message[5].round(0.001)
            ++ "] sorties [" ++ message[6].round(0.001)
            ++ ", " ++ message[7].round(0.001)
            ++ ", " ++ message[8].round(0.001)
            ++ "] apprentissage: " ++ message[9]
            ++ " son valide: " ++ message[10]
        ).postln;
    }, '/hpAudioContinuousCorrected');

    ~audioNeural = Synth(
        \hpAudioContinuousCorrected,
        [
            \inputChannel, inputChannel,
            \weightsBuf, ~audioWeights.buffer.bufnum
        ]
    );

    "Exemple audio cree. Utilisez un casque.".postln;
};
)

// 2B. Enseigner un premier geste
(
~audioNeural.set(
    \targetFilter, 0.15,
    \targetPan, 0.2,
    \targetEffect, 0.1,
    \learning, 0.01,
    \learningRate, 10,
    \learningEnabled, 1
);
)

// 2C. Suspendre l'apprentissage sans arreter le traitement
~audioNeural.set(\learningEnabled, 0);

// 2D. Enseigner un autre geste
(
~audioNeural.set(
    \targetFilter, 0.9,
    \targetPan, 0.8,
    \targetEffect, 0.75,
    \learningEnabled, 1
);
)

// 2E. Options
~audioNeural.set(\learnOnlyWithPitch, 1);
~audioNeural.set(\learnThreshold, 0.02);
~audioNeural.set(\inputGain, 2);
~audioNeural.set(\outputAmp, 0.08);

// 2F. Nettoyage audio
(
~audioNeural.notNil.if { ~audioNeural.free };
~audioWeights.notNil.if { ~audioWeights.free };
OSCdef(\audioMonitor).notNil.if { OSCdef(\audioMonitor).free };
)


// ============================================================
