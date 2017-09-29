
#define R_NO_REMAP
#include <R.h>
#include <Rinternals.h>

#include <vector>
#include <string>
#include <limits>

extern "C" SEXP split_chars(
    SEXP start_, SEXP end_,

    SEXP line1_, SEXP col1_,
    SEXP line2_, SEXP col2_,
    SEXP tokens, SEXP css
){

  /* the current line */
  std::string current_line ;
  current_line.reserve( 512 ) ; /* should be more than enough */

  int* line1      = INTEGER( line1_ );
  int* col1       = INTEGER( col1_ );
  int* line2      = INTEGER( line2_ );
  int* col2       = INTEGER( col2_ );

  int end   = INTEGER(end_)[0] ;
  int start = INTEGER(start_)[0] ;

  int n = Rf_length( tokens ) ;

  // because we don't know in advance how many strings we have
  // we use std::vector to grow/shrink
  SEXP strings = PROTECT(Rf_allocVector(STRSXP, 2*n));
  SEXP classes = PROTECT(Rf_allocVector(STRSXP, 2*n));
  SEXP SPACE   = PROTECT(Rf_mkChar("SPACE")) ;

  int line = start ;
  int col = 1;
  int i = 0, j = 0, k = 0 ;
  int nspaces = 0 ;

  for( i=0; i<n; i++){
    current_line = "" ;

    /* move down as many lines as needed */
    if( line < line1[i] ){
      for( ; line < line1[i]; line++ ){
        current_line += "\n"  ;
      }
      line = line1[i];
      col  = 1 ;
    }

    /* move right as many spaces as needed */
    if( col < col1[i] ){
      nspaces = col1[i] - col ;
      for( j=0; j<nspaces; j++){
        current_line += " "  ;
      }
    }

    /* now we arrive at a real tokens, so store the spaces */
    SET_STRING_ELT(strings, k, Rf_mkChar(current_line.c_str()) ) ;
    SET_STRING_ELT(classes, k, SPACE ) ;
    k++ ;

    /* push the real token */
    SET_STRING_ELT(strings, k, STRING_ELT(tokens, i) ) ;
    SET_STRING_ELT(classes, k, STRING_ELT(css, i) ) ;
    k++ ;

    /* set the current positions */
    col  = col2[i]+1;
    line = line2[i];
  }

  SEXP res = PROTECT(Rf_allocVector(VECSXP, 2)) ;
  SET_VECTOR_ELT(res, 0, strings) ;
  SET_VECTOR_ELT(res, 1, classes) ;

  UNPROTECT(4) ;

  return( res ) ;
}
