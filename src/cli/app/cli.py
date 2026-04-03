"""
Qtadmin CLI
"""

import typer
from importlib.metadata import version

from app.asset import refresh as asset_refresh
from app.asset import backup as asset_backup
from app.asset import audit as asset_audit


app = typer.Typer(no_args_is_help=True, invoke_without_command=True)

asset_app = typer.Typer(help="数字资产职能")
asset_app.command()(asset_refresh.refresh)
asset_app.command()(asset_backup.backup)
asset_app.command()(asset_audit.audit)

app.add_typer(asset_app, name="asset")


@app.callback(invoke_without_command=True)
def callback(
    show_version: bool = typer.Option(
        None, "--version", is_flag=True, help="显示版本号"
    ),
):
    """
    Quanttide Admin CLI
    """
    if show_version:
        typer.echo(f"qtadmin-cli {version('qtadmin-cli')}")
        raise typer.Exit()


def main():
    app()


if __name__ == "__main__":
    main()
