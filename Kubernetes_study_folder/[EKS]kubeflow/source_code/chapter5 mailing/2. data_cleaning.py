
def clean_data(input_path: str) -> str:
    import json
    import pandas as pd

    print("loading records...")
    with open(input_path, 'r') as f:
        records = json.load(f)
    print("records loaded")

    df = pd.DataFrame(records)

    #subject, body, sender가 없는 것을 그냥 drop해버려라
    cleaned = df.dropna(subnet=["subject", "body", "from"])

    output_path_hdf = '/data_processing/clean_data.hdf'
    cleaned.to_hdf(output_path_hdf, key="clean")

    return output_path_hdf