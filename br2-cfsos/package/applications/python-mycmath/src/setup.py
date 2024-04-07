from setuptools import setup, Extension

if __name__ == '__main__':
    setup(
        name = "mycmath",
        ext_modules=[Extension("mycmath",["mycmath.c"])],
        )
