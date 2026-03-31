"""
Qtadmin CLI
"""

import typer

from app.asset import refresh as asset_refresh
from app.asset import backup as asset_backup
from app.asset import audit as asset_audit

__version__ = "0.0.1-alpha.5"

app = typer.Typer(no_args_is_help=True, invoke_without_command=True)

asset_app = typer.Typer(help="数字资产职能")
asset_app.command()(asset_refresh.refresh)
asset_app.command()(asset_backup.backup)
asset_app.command()(asset_audit.audit)

app.add_typer(asset_app, name="asset")


@app.callback(invoke_without_command=True)
def callback(
    version: bool = typer.Option(None, "--version", is_flag=True, help="显示版本号"),
):
    """
    Quanttide Admin CLI
    """
    if version:
        typer.echo(f"qtadmin-cli {__version__}")
        raise typer.Exit()


def main():
    app()


if __name__ == "__main__":
    main()
