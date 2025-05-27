import sys
import re
from transformers import pipeline

generator = pipeline("text-generation", model="gpt2-medium")


def generate_threshold(score, success_rate, round_num):
    #max len limits output len
    #prompt generation defines expected behavior 
    prompt = (
        f"The player's current score is {score}, their success rate is {success_rate:.1f}% "
        f"in round {round_num}. Generate a reasonable difficulty threshold between 2 and 10 "
        f"points. Higher scores should result in harder thresholds, and lower scores in easier thresholds. "
        f"Respond with a single integer number only:" # ensures output is valid int
    )

    #temp 0.7 produces moderate level of randomness
    response = generator(
        prompt,
        max_length=len(prompt.split()) + 5,  # tightly limits response to a short answer
        temperature=0.7,
        num_return_sequences=1,
        return_full_text=False
    )
    text = response[0]['generated_text']

    #extracts ints from response
    matches = re.findall(r'\b\d+\b', text)
    for m in matches:
        val = int(m)
        if 2 <= val <= 10:
            return val
    return 3  # fallback value

if __name__ == "__main__":
    current_score = int(sys.argv[1])
    success_rate = float(sys.argv[2])
    round_num = int(sys.argv[3])

    earn_pts_thresh = generate_threshold(current_score, success_rate, round_num)
    lose_pts_thresh = generate_threshold(current_score, success_rate, round_num)
    print(earn_pts_thresh)
    print(lose_pts_thresh)
