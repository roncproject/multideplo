import os
import sys

from playwright.sync_api import sync_playwright

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))


def before_all(context):
    context.base_url = context.config.userdata.get(
        "base_url", os.environ.get("BASE_URL", "http://localhost:8080")
    )
    context.playwright = sync_playwright().start()
    context.browser = context.playwright.chromium.launch(headless=True)


def before_scenario(context, scenario):
    context.page = context.browser.new_context().new_page()


def after_scenario(context, scenario):
    context.page.close()


def after_all(context):
    context.browser.close()
    context.playwright.stop()
