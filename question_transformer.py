import json
import random
from argparse import ArgumentParser

parser = ArgumentParser()
parser.add_argument('mode', type=str)

args = parser.parse_args()
single_answer_template = '''    \t- {option}\n'''

if args.mode == 'verb':
    with open('data/spanish_verbs.json', 'r') as f_reads:
        blob = json.loads(f_reads.read())
    # verb
    #   tense
    #       pronoun

    question_template = '''
    - name: What is {pronoun} {tense} tense {base_verb} en espanol?
      options:\n{mult_choice_options}'''

    questions = set()

    for base_verb, verb_dict in blob.items():
        for tense, pronoun_map in verb_dict.items():
            for pronoun, verb_form in pronoun_map.items():
                other_options = set(pronoun_map.values()) - set([verb_form])
                all_options = list(other_options) + [f'correct{verb_form}']
                random.shuffle(all_options)
                kwargs = {
                    'base_verb': base_verb,
                    'tense': tense,
                    'pronoun': pronoun,
                }
                
                kwargs.update({
                        'mult_choice_options': ''.join(single_answer_template.format(option=item) for item in all_options)
                })
                questions.add(question_template.format(**kwargs))

    for item in questions:
        print(item)
else:
    with open('data/spanish_vocab.json', 'r') as f_reads:
        blob = json.loads(f_reads.read())
    questions = set()
    for es, en in blob.items():
            question_template = '''
    - name: What is the translation of {es} in English?
      options:\n{mult_choice_options}'''
            
            all_options = list(random.sample(list(blob.values()), 4)) + [f'correct{en}']
            random.shuffle(all_options)
            kwargs ={
                        'mult_choice_options': ''.join(single_answer_template.format(option=item) for item in all_options),
                        'es':es,

            }
            questions.add(question_template.format(**kwargs))
    for item in random.sample(questions, 100):
        print(item)
