#!/usr/bin/env python

import os
import json
import traceback
import logging

from connection import Connection

messaging = Connection()

logging.basicConfig(
    format="%(asctime)-15s [%(levelname)s] %(message)s",
    level=logging.DEBUG,
)

def callback(ch, method, properties, body):

    try:
        msg = json.loads(body.decode('utf-8'))
        logging.debug( msg )

        body_message = {
            "status": 'completed',
            "job_id": msg['job_id'],
        }

        messaging.sendJson('job_result', body_message)

    except Exception as e:
        logging.error(e)
        traceback.print_exc()
        error_content = {
            "body": body.decode('utf-8'),
            "error": "unknown"
        }
        messaging.sendJson('error', error_content)

messaging.load_configuration()

queues = [
    'job',
    'job_result',
    'error'
]

messaging.connect(queues)
messaging.consume('job', callback)
