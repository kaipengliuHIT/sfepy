/* -*- C -*- */
#ifdef SWIGPYTHON

%module fem

%{
#include "fem.h"
%}

%include "types.h"

%include common.i
%include array.i
%include fmfield.i

%apply (FMField *in) {
  (FMField *out),
  (FMField *mtx_i),
  (FMField *bc),
  (FMField *base1d),
  (FMField *coors),
  (FMField *dest_coors),
  (FMField *mesh_coors),
  (FMField *source_vals),
  (FMField *ref_coors)
};
%apply (int32 num, FMField *in) {
  (int32 n_ref_coorss, FMField *ref_coorss),
  (int32 n_mtx_is, FMField *mtx_is)
};
%apply (int32 *array, int32 n_row, int32 n_col) {
  (int32 *nodes, int32 nNod, int32 nCol),
  (int32 *cells, int32 n_cells, int32 n_cells_col)
};
%apply (int32 *array, int32 len) {
  (int32 *status, int32 n_status),
  (int32 *ics, int32 n_ics),
  (int32 *offsets, int32 n_offsets),
  (int32 *iconn0, int32 n_iconn0),
  (int32 *orders, int32 n_orders)
};

/*!
  @par Revision history:
  - 03.03.2005, c
*/
%typemap( in ) (int32 *nEl, int32 *nEP, int32 **conn) {
  PyObject *aux;
  PyArrayObject *obj;
  int32 ig, nGr;
  int32 *tnEP, *tnEl;
  int32 **tconn;

  if (!PyList_Check( $input )) {
    PyErr_SetString( PyExc_TypeError, "not a list" );
    return NULL;
  }

  nGr = PyList_Size( $input );
  tnEl = alloc_mem( int32, nGr );
  tnEP = alloc_mem( int32, nGr );
  tconn = alloc_mem( int32 *, nGr );
  for (ig = 0; ig < nGr; ig++) {
    aux = PyList_GetItem( $input, ig );
    obj = helper_get_c_array_object( aux, PyArray_INT32, 0, 0 );
    if (!obj) return NULL;
    tnEl[ig] = obj->dimensions[0];
    tnEP[ig] = obj->dimensions[1];
    tconn[ig] = (int32 *) obj->data;
    Py_DECREF( obj );
  }

  $1 = tnEl;
  $2 = tnEP;
  $3 = tconn;
};
%typemap( freearg ) (int32 *nEl, int32 *nEP, int32 **conn) {
  free_mem( $1 );
  free_mem( $2 );
  free_mem( $3 );
}

%apply (int32 *nEl, int32 *nEP, int32 **conn) {
  (int32 *nEls0, int32 *nEPs0, int32 **conns0),
  (int32 *nEls, int32 *nEPs, int32 **conns),
  (int32 *nNod, int32 *nCol, int32 **nodess)
};

int32 eval_lagrange_simplex( FMField *out, FMField *coors,
			     int32 *nodes, int32 nNod, int32 nCol,
			     int32 order, int32 diff,
			     FMField *mtx_i, FMField *bc,
			     int32 suppress_errors, float64 eps );

int32 eval_lagrange_tensor_product( FMField *out, FMField *coors,
				    int32 *nodes, int32 nNod, int32 nCol,
				    int32 order, int32 diff,
				    FMField *mtx_i, FMField *bc, FMField *base1d,
				    int32 suppress_errors, float64 eps );

int32 evaluate_at( FMField *out,
		   int32 *cells, int32 n_cells, int32 n_cells_col,
		   int32 *status, int32 n_status,
		   FMField *dest_coors, FMField *source_vals,
		   int32 *ics, int32 n_ics,
		   int32 *offsets, int32 n_offsets,
		   int32 *iconn0, int32 n_iconn0,
		   FMField *mesh_coors,
		   int32 *nEls0, int32 *nEPs0, int32 **conns0,
		   int32 *nEls, int32 *nEPs, int32 **conns,
		   int32 n_ref_coorss, FMField *ref_coorss,
		   int32 *nNod, int32 *nCol, int32 **nodess,
		   int32 *orders, int32 n_orders,
		   int32 n_mtx_is, FMField *mtx_is,
		   int32 allow_extrapolation,
		   float64 close_limit, float64 qp_eps,
		   int32 i_max, float64 newton_eps );

#endif
