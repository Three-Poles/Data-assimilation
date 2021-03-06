#include "vic.h"
using namespace ldas;

static char vcid[] = "$Id: vicerror.c,v 4.3 2006/10/18 20:59:01 vicadmin Exp $";

void Vic::vicerror(char error_text[])
/**********************************************************************
	vicerror.c	Keith Cherkauer		April 23, 1997

  This subroutine was written to handle numerical errors within the
  VIC model.  This will flush all file buffers so that all records 
  that have been run will be written to disk before the model is exited.

  Modifications:
  2006-Sep-23 Implemented flexible output configuration; uses the new
              out_data and out_data_files structures. TJB
  2006-Oct-16 Merged infiles and outfiles structs into filep_struct. TJB

**********************************************************************/
{
        //extern option_struct options;
	//extern Error_struct Error;
#if LINK_DEBUG
        //extern debug_struct debug;
#endif

        filenames_struct fnames;
	//void _exit();

        options.COMPRESS=FALSE;	/* turn off compression of last set of files */

	fprintf(stderr,"VIC model run-time error...\n");
	fprintf(stderr,"%s\n",error_text);
	fprintf(stderr,"...now writing output files...\n");
        close_files(&(Error.filep), Error.out_data_files, &fnames);
	fprintf(stderr,"...now exiting to system...\n");
        fflush(stdout);
        fflush(stderr);
	exit(1);
}
