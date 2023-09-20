import json
import random
from argparse import ArgumentParser

parser = ArgumentParser()
parser.add_argument("mode", type=str)
parser.add_argument("--format", default="yaml")

args = parser.parse_args()
single_answer_template = """    \t- {option}\n"""


if args.mode in ["verb", "conjugation"]:
    if args.mode == "verb":
        with open("data/spanish_verbs.json", "r") as f_reads:
            blob = json.loads(f_reads.read())
    else:
        with open("data/spanish_conjugation_rules.json", "r") as f_reads:
            blob = json.loads(f_reads.read())
    # verb
    #   tense
    #       pronoun

    question_template = """
    - name: What is {pronoun} {tense} tense {base_verb} en espanol?
      options:\n{mult_choice_options}"""

    questions = set()
    import itertools

    for base_verb, verb_dict in blob.items():
        candidate_others = [
            list(final_form.values())
            for final_form in [value for value in verb_dict.values()]
        ]
        candidate_others = set(itertools.chain(*candidate_others))
        for tense, pronoun_map in verb_dict.items():
            for pronoun, verb_form in pronoun_map.items():
                other_options = set(pronoun_map.values()) - set([verb_form])

                extra_wrongs = (candidate_others - other_options)-set([verb_form])
                all_options = (
                    list(other_options)
                    + [f"correct{verb_form}"]
                    + random.sample(extra_wrongs, 2)
                )
                random.shuffle(all_options)
                kwargs = {
                    "base_verb": base_verb,
                    "tense": tense,
                    "pronoun": pronoun,
                }

                kwargs.update(
                    {
                        "mult_choice_options": "".join(
                            single_answer_template.format(option=item)
                            for item in all_options
                        )
                    }
                )
                questions.add(question_template.format(**kwargs))

    for item in questions:
        print(item)
else:
    if args.mode not in ["vocab", "preposition"]:
        raise RuntimeError('Error')
    if args.mode == 'vocab':
        with open("data/spanish_vocab.json", "r") as f_reads:
            blob = json.loads(f_reads.read())
    if args.mode == 'preposition':
        with open("data/spanish_prepositions.json", "r") as f_reads:
            blob = json.loads(f_reads.read())

    questions = set()
    for es, en in blob.items():
        question_template = """
    - name: What is the translation of {es} in English?
      options:\n{mult_choice_options}"""

        all_options = list(
            item for item in random.sample(list(blob.values()), 5) if item != en
        ) + [f"correct{en}"]
        random.shuffle(all_options)
        kwargs = {
            "mult_choice_options": "".join(
                single_answer_template.format(option=item) for item in all_options
            ),
            "es": es,
        }
        questions.add(question_template.format(**kwargs))
    for item in random.sample(questions, 50):
        print(item)
