import re

def prepare_config(template_filename):
    """Throws KeyError if subs from template_filename file is not in `subs` dict
    """
    with open(template_filename) as config_template:
        lines = config_template.readlines()

    def make_subs(subs):
        config = []

        for line in lines:
            subs_var = re.search(r'{subs:(\w+)}', line)
            if subs_var:
                l, r = subs_var.span()
                v = subs_var.group(1)
                newline = line[:l] + str(subs[v]) + line[r:]
                config.append(newline)
            else:
                config.append(line)

        return config

    return make_subs
