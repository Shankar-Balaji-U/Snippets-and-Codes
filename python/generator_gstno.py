import re, random, string

PAN_REGEX = r"[A-Z]{3}[ABCEFGHJLPT]{1}[A-Z]{1}\d{4}[A-Z]{1}"
GSTIN_REGEX = r"^(3[0-7]|[1-2][0-9]|0[1-9])%s\d[Z]{1}[A-Z\d]{1}" % PAN_REGEX

ALPHABETS = string.ascii_uppercase
NUMBERS = string.digits


def generate_gstno():
    state_code = str(random.randint(1, 37)).zfill(2)
    unique_code = (
        ''.join(random.choice(ALPHABETS) for _ in range(3))
        + random.choice("ABCEFGHJLPT")
        + random.choice(ALPHABETS)
        + ''.join(random.choice(NUMBERS) for _ in range(4))
        + random.choice(ALPHABETS)
    )
    checksum = (
        random.choice(NUMBERS)
        + 'Z'
        + random.choice(ALPHABETS + NUMBERS)
    )
    
    number = state_code + unique_code + checksum
    
    if re.match(GSTIN_REGEX, number):
        return number
    return None
