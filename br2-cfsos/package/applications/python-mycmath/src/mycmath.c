#include <Python.h>

static PyObject *MyPython_add( PyObject *self, PyObject *args )
{
	double a;
	double b;

	if (!PyArg_ParseTuple(args, "dd", &a, &b))
	{
		return NULL;
	}
	return Py_BuildValue("d", a + b);
}

static struct PyMethodDef module_methods[] = {
	{ "add", MyPython_add, METH_VARARGS, NULL},
	{NULL, NULL, 0, NULL}
};

static struct PyModuleDef mycmath = {
	PyModuleDef_HEAD_INIT,
	"mycmath",
	NULL,
	-1,
	module_methods,
};

PyMODINIT_FUNC PyInit_mycmath(void)
{
   return PyModule_Create(&mycmath);
}
