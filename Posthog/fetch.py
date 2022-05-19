# %%
from ast import arg
import copy
from datetime import datetime
from datetime import timedelta
import time
import uuid
from urllib.parse import urlparse
import hashlib
import base64
import json
import pandas
import requests
from threading import Thread
from queue import Queue 
import os

# %%
posthog_scheme_and_host = 'https://posthog.structured.app'
api_key = 'phx_nXzwm5MdPRHMwfkyBAXY1SPdRyzNE7eUKYTfdHgHxg3'


def fetch_events(day: datetime.date) -> dict:
    headers = {'Authorization': 'Bearer {}'.format(api_key)}

    url = '{}/api/event?event=Icon%20Selected&after={}&before={}'.format(posthog_scheme_and_host, day.date().isoformat(), (day + timedelta(days=1)).date().isoformat())

    while 1:
        query = urlparse(url).query
        if query:
            # PostHog return weird next URL with tons of 'before' params
            comps = query.split('=')[-1]
            if comps[-2] == "before":
                url = '{}/api/event?event=Icon%20Selected&after={}&before={}'.format(posthog_scheme_and_host, day.date().isoformat(), comps[-1])

        res = requests.get(url, headers=headers)
        if res.status_code == 200:
            j_res = res.json()
            _data = j_res['results']
            print("Loaded {} for {} ({})".format(len(_data), day.date().isoformat(), urlparse(url).query))
            if len(_data) > 0:
                yield _data
            else:
                break

            if 'next' in j_res and not j_res['next'] is None:
                url = j_res['next']
            else:
                break
        else:
            print('Retry fetching events (status code: {}) from PostHog source with URL {}'.format(res.status_code, url))
            time.sleep(3)  



# %%
class TaskQueue(Queue):

    def __init__(self, num_workers=1):
        Queue.__init__(self)
        self.num_workers = num_workers
        self.start_workers()

    def add_task(self, task, *args, **kwargs):
        args = args or ()
        kwargs = kwargs or {}
        self.put((task, args, kwargs))

    def start_workers(self):
        for i in range(self.num_workers):
            t = Thread(target=self.worker)
            t.daemon = True
            t.start()

    def worker(self):
        while True:
            item, args, kwargs = self.get()
            item(*args, **kwargs)
            self.task_done()

# %%
def run(day):
    path = 'data/{}.csv'.format(day.date().isoformat())
    # if os.path.exists(path):
    #     print("Skipping", day.date().isoformat())
    # else:
    #     print("Starting", day.date().isoformat())
    for data in fetch_events(day):
        df = pandas.DataFrame(pandas.json_normalize(data))
        events = df[["properties.title", "properties.$language", "properties.icon", "id", "timestamp"]]
        # print('Loaded {} events on {}'.format(len(events), day.date().isoformat()))
        events.to_csv(path, mode='a', index=False, header=False)
    print("Finished", day.date().isoformat())


# %%

queue = TaskQueue(num_workers=3)

start_date = datetime(2021, 10, 30)

for offset in range(90):
    day = start_date - timedelta(days=offset)
    print("Adding", day.date().isoformat())
    queue.add_task(run, day)



queue.join()

print("Done!")
# %%
