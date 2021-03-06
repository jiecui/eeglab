function [node,elem,face]=cgals2m(v,f,opt,maxvol)
%
% [node,elem,face]=cgals2m(v,f,opt,maxvol)
%
% wrapper for CGAL 3D mesher (CGAL 3.5 and newer)
% convert a binary (or multi-valued) volume to tetrahedral mesh
%
% http://www.cgal.org/Manual/3.5/doc_html/cgal_manual/Mesh_3/Chapter_main.html
%
% author: Qianqian Fang (fangq <at> nmr.mgh.harvard.edu)
%
% input:
%	 v: the node coordinate list of a surface mesh (nn x 3)
%	 f: the face element list of a surface mesh (be x 3)
%	 opt: parameters for CGAL mesher, if opt is a structure, then
%	     opt.radbound: defines the maximum surface element size
%	     opt.angbound: defines the miminum angle of a surface triangle
%	     opt.distbound: defines the maximum distance between the 
%		 center of the surface bounding circle and center of the 
%		 element bounding sphere
%	     opt.reratio:  maximum radius-edge ratio
%	     if opt is a scalar, it only specifies radbound.
%	 maxvol: target maximum tetrahedral elem volume
%
% output:
%	 node: output, node coordinates of the tetrahedral mesh
%	 elem: output, element list of the tetrahedral mesh, the last 
%	      column is the region id
%	 face: output, mesh surface element list of the tetrahedral mesh
%	      the last column denotes the boundary ID
%
% -- this function is part of iso2mesh toolbox (http://iso2mesh.sf.net)
%

fprintf(1,'creating surface and tetrahedral mesh from a polyhedral surface ...\n');

exesuff=getexeext;
exesuff=fallbackexeext(exesuff,'cgalpoly');

ang=30;
ssize=6;
approx=0.5;
reratio=3;

if(~isstruct(opt))
	ssize=opt;
end

if(isstruct(opt) & length(opt)==1)  % does not support settings for multiple labels
	if(isfield(opt,'radbound'))   ssize=opt.radbound; end
	if(isfield(opt,'angbound'))   ang=opt.angbound; end
	if(isfield(opt,'distbound'))  approx=opt.distbound; end
	if(isfield(opt,'reratio'))    reratio=opt.reratio; end
end
[v,f]=meshcheckrepair(v,f);
saveoff(v,f,mwpath('pre_cgalpoly.off'));
deletemeshfile(mwpath('post_cgalpoly.mesh'));

randseed=hex2dec('623F9A9E'); % "U+623F U+9A9E"

if(~isempty(getvarfrom('base','ISO2MESH_RANDSEED')))
        randseed=getvarfrom('base','ISO2MESH_RANDSEED');
end

cmd=sprintf('"%s%s" "%s" "%s" %f %f %f %f %f %d',mcpath('cgalpoly'),exesuff,...
    mwpath('pre_cgalpoly.off'),mwpath('post_cgalpoly.mesh'),ang,ssize,...
    approx,reratio,maxvol,randseed);
system(cmd);
if(~exist(mwpath('post_cgalpoly.mesh'),'file'))
    error(sprintf('output file was not found, failure was encountered when running command: \n%s\n',cmd));
end
[node,elem,face]=readmedit(mwpath('post_cgalpoly.mesh'));

fprintf(1,'node number:\t%d\ntriangles:\t%d\ntetrahedra:\t%d\nregions:\t%d\n',...
    size(node,1),size(face,1),size(elem,1),length(unique_bc(elem(:,end))));
fprintf(1,'surface and volume meshes complete\n');
