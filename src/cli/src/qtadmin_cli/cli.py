"""
Qtadmin CLI
"""

import typer

from qtadmin_cli.meta import refresh as meta_refresh

__version__ = "0.0.1"

app = typer.Typer(no_args_is_help=True, invoke_without_command=True)

app.add_typer(meta_refresh.app, name="meta")


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
