// This file demonstrates how patterns can be used to change the chord and scale context...
// ...as well as just specifying notes

// Execute this block to create the synth defs
(
SynthDef(\saw,
	{
		|freq = 200, amp = 0.2, pan = 0, out = 0, gate = 1, detune = 0.1, cutoff = 1000|
		var audio, env, filtEnv, brightness;
		freq = freq + (freq * LFNoise1.kr(0.3).bipolar(0.006));
		env = EnvGen.kr(Env.adsr, gate, amp, doneAction: 2);
		filtEnv = EnvGen.kr(Env.perc(releaseTime: amp * 10), gate, cutoff, cutoff/2);
		freq = [freq, freq + (freq * detune)];
		audio = Saw.ar(freq, env);
		audio = BPF.ar(audio, filtEnv);
		audio = Pan2.ar(audio, pan);
		Out.ar(out, audio);
	}
).add;
SynthDef(\sine,
	{
		|freq = 200, amp = 0.2, pan = 0, out = 0, gate = 1, lag = 0.1|
		var audio, env;
		freq = VarLag.kr(freq, lag, warp: \sine);
		freq = freq + (freq * LFNoise1.kr(LFNoise1.kr(0.2).exprange(0.2,2)).bipolar(0.02));
		env = EnvGen.kr(Env.cutoff(2), gate, amp, doneAction: 2);
		audio = SinOsc.ar(freq, mul: env);
		audio = Pan2.ar(audio, pan);
		Out.ar(out, audio);
	}
).add;
)

// Execute this block to set C major chord for the pattern to follow
(
~scale = Scale.major;
~chord = [0,2,4];
)

// Execute this block to start a one-bar pattern
(
Pdef(\patterns,
	Ppar([
		Pbind(
			\scale, Pfunc({~scale}),
			\instrument, \saw,
			\octave, Pwrand([5,6],[0.95,0.05],inf),
			\melody, Pseq([0,1,0,2],inf),
			\degree, Pkey(\melody).collect({|x| ~chord[x]}),
			\cutoff, Pwhite(500,1500),
			\dur, 0.25,
			\out, 0
		),
		Pbind(
			\scale, Pfunc({~scale}),
			\instrument, \saw,
			\melody, Prand((0..2),inf),
			\octave, 3,
			//\octave, Pbrown(5,8,1,inf), // Uncomment and re-execute for nice sound
			\degree, Pkey(\melody).collect({|x| ~chord[x]}),
			\cutoff, Pwhite(200,800),
			\dur, 0.125,
			\out, 0
		),
		Pmono(
			\sine,
			\scale, Pfunc({~scale}),
			\melody, Pbrown(0,2,1,inf),
			\octave, Pbrown(5,8,1,inf),
			\degree, Pkey(\melody).collect({|x| ~chord[x]}),
			\dur, Prand([Pseq([0.125],8),Pseq([0.25],4),Pseq([0.5],2),Pseq([1],1)],inf),
			\amp, 0.03,
			\lag, 0.03,
			\pan, Pwhite(-1.0,1,inf),
			\out, nil // Change to 0 and re-execute for annoying meandering sine
		)
	])
).play;
)

// Stop the one-bar pattern when you're tired of it!
Pdef(\patterns).stop

// Execute this block to start the chord and scale patterns
(
Pdef(\scales,
	Pbind(
		\type, \rest, // Prevents the pattern trying to play notes
		\scaleSequence, Pseq([Scale.major,Scale.aeolian,Scale.lydian,Scale.phrygian],inf),
		\current, Pkey(\scaleSequence).collect({|x| ~scale = x}).trace,
		\dur, 7 // Scale changes every 7 bars, which is the length of the chord sequence
	)
).play;
Pdef(\chords,
	Pbind(
		\type, \rest, // Prevents the pattern trying to play notes
		\chordSequence, Pseq([[0,2,4],[-1,3,6],[0,2,4],[-1,3,6],[0,2,4],[-1,3,6],[1,4,7]],inf),
		\current, Pkey(\chordSequence).collect({|x| ~chord = x}),
		\dur, 1 // Chord changes every bar
	)
).play;
)

// Stop the chord and scale patterns - will then just keep repeating the same chord
Pdef(\scales).stop;
Pdef(\chords).stop;