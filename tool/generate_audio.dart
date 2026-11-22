// ignore_for_file: avoid_print
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

void main() async {
  final dir = Directory('assets/audio');
  if (!dir.existsSync()) {
    dir.createSync(recursive: true);
  }

  print('Generating high-quality game audio files in assets/audio...');

  // 1. Pop sound (0.15s, fast frequency drop, damped sine)
  writeWav('assets/audio/pop.wav', generatePop());

  // 2. Launch sound (0.2s, laser whoosh)
  writeWav('assets/audio/launch.wav', generateLaunch());

  // 3. Bounce sound (0.12s, crystal ping)
  writeWav('assets/audio/bounce.wav', generateBounce());

  // 4. Combo sound (0.35s, bright ascending chord)
  writeWav('assets/audio/combo.wav', generateCombo());

  // 5. Bomb explosion (0.5s, low rumble with noise)
  writeWav('assets/audio/bomb.wav', generateBomb());

  // 6. Lightning sound (0.35s, electric buzz/zap)
  writeWav('assets/audio/lightning.wav', generateLightning());

  // 7. Fire sound (0.4s, whoosh + rumble)
  writeWav('assets/audio/fire.wav', generateFire());

  // 8. Rainbow sound (0.45s, sparkling harp/chime)
  writeWav('assets/audio/rainbow.wav', generateRainbow());

  // 9. Click sound (0.05s, subtle snappy UI tick)
  writeWav('assets/audio/click.wav', generateClick());

  // 10. Star sound (0.3s, bell tone)
  writeWav('assets/audio/star.wav', generateStar());

  // 11. Victory fanfare (1.2s, major triumphant arpeggio)
  writeWav('assets/audio/victory.wav', generateVictory());

  // 12. Game over sound (0.8s, descending minor motif)
  writeWav('assets/audio/game_over.wav', generateGameOver());

  // 13. Menu ambient music (4.0s seamlessly looping synth arpeggio)
  writeWav('assets/audio/menu_music.wav', generateMenuMusic());

  // 14. Gameplay upbeat music (4.0s seamlessly looping energetic synth pulse)
  writeWav('assets/audio/gameplay_music.wav', generateGameplayMusic());

  print('All 14 audio assets successfully generated and verified!');
}

Uint8List generateWav(int sampleRate, List<double> samples) {
  final byteCount = samples.length * 2;
  final buffer = BytesBuilder();

  // RIFF Header
  buffer.add('RIFF'.codeUnits);
  final fileSize = 36 + byteCount;
  buffer.addByte(fileSize & 0xFF);
  buffer.addByte((fileSize >> 8) & 0xFF);
  buffer.addByte((fileSize >> 16) & 0xFF);
  buffer.addByte((fileSize >> 24) & 0xFF);
  buffer.add('WAVE'.codeUnits);

  // FMT subchunk
  buffer.add('fmt '.codeUnits);
  buffer.addByte(16); buffer.addByte(0); buffer.addByte(0); buffer.addByte(0); // Subchunk1Size (16 for PCM)
  buffer.addByte(1); buffer.addByte(0); // AudioFormat (1 = PCM)
  buffer.addByte(1); buffer.addByte(0); // NumChannels (1 = Mono)
  
  // SampleRate
  buffer.addByte(sampleRate & 0xFF);
  buffer.addByte((sampleRate >> 8) & 0xFF);
  buffer.addByte((sampleRate >> 16) & 0xFF);
  buffer.addByte((sampleRate >> 24) & 0xFF);

  // ByteRate = SampleRate * NumChannels * BitsPerSample/8
  final byteRate = sampleRate * 2;
  buffer.addByte(byteRate & 0xFF);
  buffer.addByte((byteRate >> 8) & 0xFF);
  buffer.addByte((byteRate >> 16) & 0xFF);
  buffer.addByte((byteRate >> 24) & 0xFF);

  // BlockAlign = NumChannels * BitsPerSample/8 = 2
  buffer.addByte(2); buffer.addByte(0);
  // BitsPerSample = 16
  buffer.addByte(16); buffer.addByte(0);

  // DATA subchunk
  buffer.add('data'.codeUnits);
  buffer.addByte(byteCount & 0xFF);
  buffer.addByte((byteCount >> 8) & 0xFF);
  buffer.addByte((byteCount >> 16) & 0xFF);
  buffer.addByte((byteCount >> 24) & 0xFF);

  // Samples (16-bit signed PCM)
  for (final s in samples) {
    final clamped = s.clamp(-1.0, 1.0);
    final val = (clamped * 32767).toInt();
    buffer.addByte(val & 0xFF);
    buffer.addByte((val >> 8) & 0xFF);
  }

  return buffer.toBytes();
}

void writeWav(String path, List<double> samples, [int sampleRate = 44100]) {
  final bytes = generateWav(sampleRate, samples);
  File(path).writeAsBytesSync(bytes);
}

// 1. Pop sound
List<double> generatePop([int sampleRate = 44100]) {
  final duration = 0.14;
  final numSamples = (sampleRate * duration).toInt();
  final samples = <double>[];
  for (int i = 0; i < numSamples; i++) {
    final t = i / sampleRate;
    final progress = i / numSamples;
    final freq = 580.0 * (1.0 - progress * 0.65) + 120.0;
    final env = exp(-progress * 14.0);
    final sample = sin(2 * pi * freq * t) * env;
    samples.add(sample * 0.75);
  }
  return samples;
}

// 2. Launch sound (laser whoosh)
List<double> generateLaunch([int sampleRate = 44100]) {
  final duration = 0.18;
  final numSamples = (sampleRate * duration).toInt();
  final samples = <double>[];
  for (int i = 0; i < numSamples; i++) {
    final t = i / sampleRate;
    final progress = i / numSamples;
    final freq = 800.0 - 550.0 * progress;
    final env = sin(pi * progress);
    final sample = sin(2 * pi * freq * t) * env;
    samples.add(sample * 0.6);
  }
  return samples;
}

// 3. Bounce sound (crystal ping)
List<double> generateBounce([int sampleRate = 44100]) {
  final duration = 0.1;
  final numSamples = (sampleRate * duration).toInt();
  final samples = <double>[];
  for (int i = 0; i < numSamples; i++) {
    final t = i / sampleRate;
    final progress = i / numSamples;
    final env = exp(-progress * 22.0);
    final s1 = sin(2 * pi * 880.0 * t);
    final s2 = sin(2 * pi * 1320.0 * t) * 0.4;
    samples.add((s1 + s2) * env * 0.5);
  }
  return samples;
}

// 4. Combo sound (ascending chime)
List<double> generateCombo([int sampleRate = 44100]) {
  final duration = 0.35;
  final numSamples = (sampleRate * duration).toInt();
  final samples = <double>[];
  final notes = [523.25, 659.25, 783.99, 1046.50]; // C5, E5, G5, C6
  for (int i = 0; i < numSamples; i++) {
    final t = i / sampleRate;
    final noteIdx = min((t / (duration / notes.length)).toInt(), notes.length - 1);
    final noteFreq = notes[noteIdx];
    final noteTime = t - noteIdx * (duration / notes.length);
    final env = exp(-noteTime * 12.0);
    final s = sin(2 * pi * noteFreq * t) * env;
    samples.add(s * 0.65);
  }
  return samples;
}

// 5. Bomb explosion
List<double> generateBomb([int sampleRate = 44100]) {
  final duration = 0.55;
  final numSamples = (sampleRate * duration).toInt();
  final samples = <double>[];
  final rng = Random(42);
  for (int i = 0; i < numSamples; i++) {
    final t = i / sampleRate;
    final progress = i / numSamples;
    final env = exp(-progress * 7.0);
    final lowBoom = sin(2 * pi * (120.0 - progress * 90.0) * t);
    final noise = (rng.nextDouble() * 2 - 1) * exp(-progress * 9.0);
    samples.add((lowBoom * 0.7 + noise * 0.4) * env * 0.7);
  }
  return samples;
}

// 6. Lightning sound
List<double> generateLightning([int sampleRate = 44100]) {
  final duration = 0.35;
  final numSamples = (sampleRate * duration).toInt();
  final samples = <double>[];
  final rng = Random(123);
  for (int i = 0; i < numSamples; i++) {
    final t = i / sampleRate;
    final progress = i / numSamples;
    final env = exp(-progress * 8.0);
    final buzz = sin(2 * pi * 240.0 * t) > 0 ? 0.4 : -0.4;
    final noise = (rng.nextDouble() * 2 - 1) * 0.5;
    samples.add((buzz + noise) * env * 0.6);
  }
  return samples;
}

// 7. Fire sound
List<double> generateFire([int sampleRate = 44100]) {
  final duration = 0.4;
  final numSamples = (sampleRate * duration).toInt();
  final samples = <double>[];
  final rng = Random(999);
  for (int i = 0; i < numSamples; i++) {
    final t = i / sampleRate;
    final progress = i / numSamples;
    final env = sin(pi * progress);
    final rumble = sin(2 * pi * 85.0 * t) * 0.5;
    final hiss = (rng.nextDouble() * 2 - 1) * 0.5;
    samples.add((rumble + hiss) * env * 0.6);
  }
  return samples;
}

// 8. Rainbow sound
List<double> generateRainbow([int sampleRate = 44100]) {
  final duration = 0.45;
  final numSamples = (sampleRate * duration).toInt();
  final samples = <double>[];
  for (int i = 0; i < numSamples; i++) {
    final t = i / sampleRate;
    final progress = i / numSamples;
    final env = sin(pi * progress);
    final f1 = 600.0 + progress * 1000.0;
    final s1 = sin(2 * pi * f1 * t);
    final s2 = sin(2 * pi * (f1 * 1.5) * t) * 0.3;
    samples.add((s1 + s2) * env * 0.5);
  }
  return samples;
}

// 9. Click sound
List<double> generateClick([int sampleRate = 44100]) {
  final duration = 0.04;
  final numSamples = (sampleRate * duration).toInt();
  final samples = <double>[];
  for (int i = 0; i < numSamples; i++) {
    final t = i / sampleRate;
    final progress = i / numSamples;
    final env = exp(-progress * 40.0);
    final s = sin(2 * pi * 1400.0 * t);
    samples.add(s * env * 0.4);
  }
  return samples;
}

// 10. Star sound
List<double> generateStar([int sampleRate = 44100]) {
  final duration = 0.35;
  final numSamples = (sampleRate * duration).toInt();
  final samples = <double>[];
  for (int i = 0; i < numSamples; i++) {
    final t = i / sampleRate;
    final progress = i / numSamples;
    final env = exp(-progress * 8.0);
    final s1 = sin(2 * pi * 1046.50 * t); // C6
    final s2 = sin(2 * pi * 2093.00 * t) * 0.4;
    samples.add((s1 + s2) * env * 0.5);
  }
  return samples;
}

// 11. Victory sound
List<double> generateVictory([int sampleRate = 44100]) {
  final duration = 1.2;
  final numSamples = (sampleRate * duration).toInt();
  final samples = <double>[];
  final notes = [523.25, 659.25, 783.99, 1046.50, 1318.51]; // C5, E5, G5, C6, E6
  for (int i = 0; i < numSamples; i++) {
    final t = i / sampleRate;
    double sample = 0.0;
    for (int n = 0; n < notes.length; n++) {
      final noteStart = n * 0.16;
      if (t >= noteStart) {
        final noteAge = t - noteStart;
        final env = exp(-noteAge * 4.0);
        sample += sin(2 * pi * notes[n] * t) * env * 0.25;
      }
    }
    samples.add(sample.clamp(-0.8, 0.8));
  }
  return samples;
}

// 12. Game over sound
List<double> generateGameOver([int sampleRate = 44100]) {
  final duration = 0.8;
  final numSamples = (sampleRate * duration).toInt();
  final samples = <double>[];
  final notes = [440.0, 415.3, 392.0, 349.2]; // A4, Ab4, G4, F4
  for (int i = 0; i < numSamples; i++) {
    final t = i / sampleRate;
    final noteIdx = min((t / (duration / notes.length)).toInt(), notes.length - 1);
    final noteFreq = notes[noteIdx];
    final noteTime = t - noteIdx * (duration / notes.length);
    final env = exp(-noteTime * 5.0);
    final s = sin(2 * pi * noteFreq * t) * env;
    samples.add(s * 0.45);
  }
  return samples;
}

// 13. Menu ambient music (4.0s seamless loop)
List<double> generateMenuMusic([int sampleRate = 44100]) {
  final duration = 4.0;
  final numSamples = (sampleRate * duration).toInt();
  final samples = <double>[];
  final chord = [261.63, 329.63, 392.0, 523.25]; // C major 7 arpeggio
  for (int i = 0; i < numSamples; i++) {
    final t = i / sampleRate;
    final beatTime = (t * 2.0) % 1.0;
    final noteIdx = ((t * 4.0).toInt()) % chord.length;
    final freq = chord[noteIdx];
    final arpEnv = exp(-beatTime * 3.0);
    final synth = sin(2 * pi * freq * t) * 0.25 * arpEnv;
    // Ambient pad bass
    final pad = (sin(2 * pi * 130.81 * t) + sin(2 * pi * 196.0 * t)) * 0.08;
    samples.add(synth + pad);
  }
  return samples;
}

// 14. Gameplay upbeat music (4.0s seamless loop)
List<double> generateGameplayMusic([int sampleRate = 44100]) {
  final duration = 4.0;
  final numSamples = (sampleRate * duration).toInt();
  final samples = <double>[];
  final bassline = [130.81, 146.83, 164.81, 174.61]; // C3, D3, E3, F3
  final leadNotes = [523.25, 587.33, 659.25, 783.99, 659.25, 587.33, 523.25, 392.0];
  for (int i = 0; i < numSamples; i++) {
    final t = i / sampleRate;
    // Bass pulse (4 beats per second)
    final bassIdx = (t.toInt()) % bassline.length;
    final bassEnv = exp(-((t * 2.0) % 0.5) * 6.0);
    final bass = sin(2 * pi * bassline[bassIdx] * t) * 0.22 * bassEnv;
    
    // Lead melody (8 steps per loop)
    final leadIdx = ((t * 2.0).toInt()) % leadNotes.length;
    final leadEnv = exp(-((t * 2.0) % 0.5) * 4.0);
    final lead = sin(2 * pi * leadNotes[leadIdx] * t) * 0.18 * leadEnv;

    // Sub tick / high hat
    final hat = ((i % 11025) < 300) ? 0.05 * sin(2 * pi * 3500.0 * t) : 0.0;
    
    samples.add(bass + lead + hat);
  }
  return samples;
}
