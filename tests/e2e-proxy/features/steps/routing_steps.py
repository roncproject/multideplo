from behave import when, then

from pages.game_home_page import GameHomePage


@when('I open "{path}"')
def step_open(context, path):
    context.response = context.page.goto(context.base_url + path)


@when('I request "{path}"')
def step_request(context, path):
    context.response = context.page.request.get(context.base_url + path)


@then("the response status is {code:d}")
def step_status(context, code):
    assert context.response.status == code, (
        f"expected {code}, got {context.response.status} for "
        f"{context.response.url}"
    )


@then("the page shows the RuhRohgue game")
def step_game_shown(context):
    home = GameHomePage(context.page)
    assert home.is_loaded(), "titlebar/dungeon-grid not found on page"
