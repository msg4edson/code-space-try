import json
import logging
import os

logger = logging.getLogger()
logger.setLevel(logging.INFO)


def lambda_handler(event: dict, context) -> dict:
    """
    Scheduled Lambda handler triggered by EventBridge.

    Parameters
    ----------
    event   : dict  – EventBridge scheduled event payload
    context : LambdaContext – runtime information provided by AWS Lambda
    """
    logger.info("Event received: %s", json.dumps(event))

    # Example: read an environment variable
    stage = os.environ.get("STAGE", "dev")
    logger.info("Running in stage: %s", stage)

    # ---------------------------------------------------------------------------
    # TODO: add your business logic here
    # ---------------------------------------------------------------------------
    result = {
        "status": "ok",
        "stage": stage,
        "request_id": context.aws_request_id,
    }

    logger.info("Result: %s", json.dumps(result))
    return result
