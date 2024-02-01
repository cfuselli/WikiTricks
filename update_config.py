import configparser

DEFAULT_CONFIG_PATH = 'example.ini'

def update_ini_file(key, value, file_path=DEFAULT_CONFIG_PATH):
    """
    Update a specified key with a new value in an INI file.

    :param file_path: Path to the INI file
    :param key: Key to be updated
    :param value: New value for the key
    """
    config = configparser.ConfigParser()
    config.read(file_path)

    # Iterate over all sections and update the key if found
    updated = False
    for section in config.sections():
        if key in config[section]:
            config[section][key] = value
            updated = True
            break

    # Write changes back to file if the key was found and updated
    if updated:
        with open(file_path, 'w') as configfile:
            config.write(configfile)
        print(f"Updated '{key}' with '{value}', section '{section}'")
    else:
        # Key was not found in any section
        # Let's add it to the DEFAULT section instead
        # If it doesn't exist, it will be created
        config['DEFAULT'][key] = value
        with open(file_path, 'w') as configfile:
            config.write(configfile)

        print(f"Added '{key}' with '{value}' to the DEFAULT section")

    return 0