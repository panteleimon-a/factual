try:
    import os
    import random
    import io
    import json
    from pathlib import Path
    from factualweb.settings import BASE_DIR
except ImportError:
    pass

def get_useragent():
    # random select agent (search will be conducted in Google Cloud env, this part doesn't impact our code)
    # Build paths inside the project like this: BASE_DIR / 'subdir'.
    PROXIES = os.path.join(BASE_DIR,'bert/parser/useragent-data.json')
    path_to_json=PROXIES
    with io.open(path_to_json, encoding='utf-8-sig') as json_data:
        data = json.loads(json_data.read())
    return random.choice(data)