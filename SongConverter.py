import os
import numpy as np
import random
import pretty_midi
import librosa

INSTRUMENT_TO_LANE = {
    'Flute': 0,
    'Harp': 1,
    'Drums': 2,
    'Lute': 3
}

def instrument_name(instr):
    if instr.is_drum:
        return 'Drums'
    prog_name = pretty_midi.program_to_instrument_name(instr.program)
    if 'Flute' in prog_name:
        return 'Flute'
    elif 'Harp' in prog_name or 'Celesta' in prog_name :   
        return 'Harp'
    elif 'Lute' in prog_name or 'Guitar' in prog_name:
        return 'Lute'
    elif 'Drums' in prog_name or 'Synth Drum' in prog_name:
        return 'Drums'
    return None

def extract_from_midi(midi_path):
    midi_data = pretty_midi.PrettyMIDI(midi_path)
    lanes = [[] for _ in range(4)]
    for instr in midi_data.instruments:
        name = instrument_name(instr)
        if name is None:
            continue
        lane = INSTRUMENT_TO_LANE[name]
        for note in instr.notes:
            frame = int(round(note.start * 60))
            lanes[lane].append(frame)
    for lane in lanes:
        lane.sort()
    return lanes

def extract_from_audio(audio_path, sr=22050):
    y, _ = librosa.load(audio_path, sr=sr)
    onset_frames = librosa.onset.onset_detect(y=y, sr=sr, units='frames', backtrack=True)
    onset_times = librosa.frames_to_time(onset_frames, sr=sr)
    onset_60fps = np.round(onset_times * 60).astype(int)
    lanes = [[] for _ in range(4)]
    for t in onset_60fps:
        lane = random.randint(0, 3)
        lanes[lane].append(int(t))
    for lane in lanes:
        lane.sort()
    return lanes

def format_output(lanes):
    lines = []
    for lane in lanes:
        line = [str(len(lane))] + [str(t) for t in lane]
        lines.append(' '.join(line))
    return '\n'.join(lines)

def save_output(text, input_path):
    output_dir = os.path.join("Main", "data", "Songs")
    os.makedirs(output_dir, exist_ok=True)
    base_name = os.path.splitext(os.path.basename(input_path))[0]
    output_path = os.path.join(output_dir, base_name + ".txt")
    with open(output_path, 'w') as f:
        f.write(text)
    print(f"Output saved to {output_path}")

def generate(mode, input_path):
    if mode == 'midi':
        lanes = extract_from_midi(input_path)
    elif mode == 'audio':
        lanes = extract_from_audio(input_path)
    else:
        raise ValueError("Mode must be 'midi' or 'audio'.")

    for i in range(len(lanes)):
        lanes[i] = quantize_notes(lanes[i], grid=5)
        lanes[i] = filter_notes(lanes[i], min_spacing=60)

    output = format_output(lanes)
    save_output(output, input_path)

def filter_notes(notes, min_spacing=10):
    notes.sort()
    filtered = []
    last_time = -min_spacing
    for n in notes:
        if n - last_time >= min_spacing:
            filtered.append(n)
            last_time = n
    return filtered

def quantize_notes(notes, grid=5):
    return sorted(set([(n // grid) * grid for n in notes]))

if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument('--mode', choices=['midi', 'audio'], required=True)
    parser.add_argument('--input', required=True)
    args = parser.parse_args()
    generate(args.mode, args.input)

# How to use for bogden ->
# paste in terminal python SongConverter.py --mode midi --input Main/data/SongAudio/[whatever].mid
# or python SongConverter.py --mode audio --input Main/data/SongAudio/[whatever].mp3
# make sure u install the stuff 
# pip install np pretty_midi librosa
