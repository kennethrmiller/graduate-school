import time
import requests
from retrying import retry
import ujson
from confluent_kafka import Producer
from confluent_kafka.admin import AdminClient, NewTopic
import json

admin = AdminClient({'bootstrap.servers': 'kafka-1:9092'})

metadata = admin.list_topics(timeout=10)
topics = metadata.topics

if 'citibike.station.update.1' not in topics:
	admin.create_topics([NewTopic('citibike.station.update.1', num_partitions = 3, replication_factor = 1)])

p = Producer({'bootstrap.servers': 'kafka-1:9092',
              'api.version.request': True})

@retry(wait_exponential_multiplier = 1000, wait_exponential_max=10000)
def scrape_station_status():
	r = requests.get('https://gbfs.citibikenyc.com/gbfs/en/station_status.json')
	if r.status_code != 200:
        	raise IOError('Failed request.')
	else:
		print('scraping data')
	return ujson.loads(r.content.decode('utf-8'))

scrape_station_status()

while True:
# if request fails, back off on the request insanity
	data = scrape_station_status()
	# put data into kafka
	jd = json.dumps(data)
	p.produce('citibike.station.update.1',jd)
p.flush()

