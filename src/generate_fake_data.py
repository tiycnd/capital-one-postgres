import csv
import random
from faker import Faker

fake = Faker()

# columns
# id, system_id, name, priority (1-5), key

#seed = random.getrandbits(32)
seed = 2113004341

with open('users.csv', 'w') as csvfile:
  writer = csv.writer(csvfile)
  for i in range(1000000):
    writer.writerow([i, seed, fake.name(), random.randint(1,5), fake.pystr(min_chars=15, max_chars=20)])
    seed += random.randint(1, 4)