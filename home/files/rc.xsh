# pylint: disable=missing-module-docstring

import builtins  # pylint: disable=unused-import
import os
import os.path
import subprocess
import sys
import typing

import xonsh.dirstack  # type: ignore # pylint: disable=import-error
import xonsh.environ  # type: ignore # pylint: disable=import-error

# =============================================================================
#
# Utility functions for zoxide.
#


def __zoxide_bin() -> str:
    """Finds and returns the location of the zoxide binary."""
    zoxide = typing.cast(str, xonsh.environ.locate_binary("zoxide"))
    if zoxide is None:
        zoxide = "zoxide"
    return zoxide


def __zoxide_env() -> typing.Dict[str, str]:
    """Returns the current environment."""
    return builtins.__xonsh__.env.detype()  # type: ignore  # pylint:disable=no-member


def __zoxide_pwd() -> str:
    """pwd based on the value of _ZO_RESOLVE_SYMLINKS."""
    pwd = __zoxide_env().get("PWD")
    if pwd is None:
        raise RuntimeError("$PWD not found")
    return pwd


def __zoxide_cd(path: typing.Optional[typing.AnyStr] = None) -> None:
    """cd + custom logic based on the value of _ZO_ECHO."""
    if path is None:
        args = []
    elif isinstance(path, bytes):
        args = [path.decode("utf-8")]
    elif isinstance(path, str):
        args = [path]
    _, exc, _ = xonsh.dirstack.cd(args)
    if exc is not None:
        raise RuntimeError(exc)


class ZoxideSilentException(Exception):
    """Exit without complaining."""


def __zoxide_errhandler(
    func: typing.Callable[[typing.List[str]], None]
) -> typing.Callable[[typing.List[str]], int]:
    """Print exception and exit with error code 1."""

    def wrapper(args: typing.List[str]) -> int:
        try:
            func(args)
            return 0
        except ZoxideSilentException:
            return 1
        except Exception as exc:  # pylint: disable=broad-except
            print(f"zoxide: {exc}", file=sys.stderr)
            return 1

    return wrapper


# =============================================================================
#
# Hook configuration for zoxide.
#

# Initialize hook to add new entries to the database.
if "__zoxide_hook" not in globals():

    @builtins.events.on_chdir  # type: ignore  # pylint:disable=no-member
    def __zoxide_hook(**_kwargs: typing.Any) -> None:
        """Hook to add new entries to the database."""
        pwd = __zoxide_pwd()
        zoxide = __zoxide_bin()
        subprocess.run(
            [zoxide, "add", "--", pwd],
            check=False,
            env=__zoxide_env(),
        )


# =============================================================================
#
# When using zoxide with --no-cmd, alias these internal functions as desired.
#


@__zoxide_errhandler
def __zoxide_z(args: typing.List[str]) -> None:
    """Jump to a directory using only keywords."""
    if args == []:
        __zoxide_cd()
    elif args == ["-"]:
        __zoxide_cd("-")
    elif len(args) == 1 and os.path.isdir(args[0]):
        __zoxide_cd(args[0])
    else:
        try:
            zoxide = __zoxide_bin()
            cmd = subprocess.run(
                [zoxide, "query", "--exclude", __zoxide_pwd(), "--"] + args,
                check=True,
                env=__zoxide_env(),
                stdout=subprocess.PIPE,
            )
        except subprocess.CalledProcessError as exc:
            raise ZoxideSilentException() from exc

        result = cmd.stdout[:-1]
        __zoxide_cd(result)


@__zoxide_errhandler
def __zoxide_zi(args: typing.List[str]) -> None:
    """Jump to a directory using interactive search."""
    try:
        zoxide = __zoxide_bin()
        cmd = subprocess.run(
            [zoxide, "query", "-i", "--"] + args,
            check=True,
            env=__zoxide_env(),
            stdout=subprocess.PIPE,
        )
    except subprocess.CalledProcessError as exc:
        raise ZoxideSilentException() from exc

    result = cmd.stdout[:-1]
    __zoxide_cd(result)


# =============================================================================
#
# Commands for zoxide. Disable these using --no-cmd.
#

builtins.aliases["z"] = __zoxide_z  # type: ignore  # pylint:disable=no-member
builtins.aliases["zi"] = __zoxide_zi  # type: ignore  # pylint:disable=no-member

# =============================================================================
#
# To initialize zoxide, add this to your configuration (usually ~/.xonshrc):
#
# execx($(zoxide init xonsh), 'exec', __xonsh__.ctx, filename='zoxide')

import prompt_starship

$XONTRIB_PROMPT_STARSHIP_LEFT_CONFIG = "~/.config/starship_xonsh_left.toml"
$XONTRIB_PROMPT_STARSHIP_RIGHT_CONFIG = "~/.config/starship_xonsh_right.toml"
$XONTRIB_PROMPT_STARSHIP_BOTTOM_CONFIG = "~/.config/starship_xonsh_bottom.toml"

xontrib load coreutils
