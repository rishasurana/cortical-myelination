function mat2bmp(a_name, a_mat, varargin)
%MAT2BMP Write matrix to standard windows bitmap file.
%   MAT2BMP(FILENAME,MATRIX) writes a standard windows bitmap file (24-bit 
%   color)to a file called FILENAME (created or overwritten) whose image 
%   matches the image represented by a_mat. No scaling is performed on the 
%   image data. If the matrix is MxN (2-D) the image is created with 
%   colors mapped to the colormap passed into varargin{1}, or the existing
%   current ML colomap if no colormap is passed in varargin. If matrix is 
%   MxNx3, the first layer of the matrix ( MATRIX(:,:,1) ) is assumed red
%   data, second green, and third blue. 
% 
%   See File for futher notes, revision history, future updates, and
%   contact information.
% 
%   Example: write a sample membrane image to a bmp file:
%       z = membrane(1,100,9,2); %create a sample image
%       imagesc(z); %preview what the image should look like
%       mat2bmp('SampleMembrane.bmp',z); %write the 'image' to the file
%
%   See also (MATLAB Central F-Ex) BMP2MAT, IMWRITE, IMAGESC

%   Notes:
%       -I wrote this as a study of bitmap file structure. I'm sure are a
%       dozen other/faster/better ways to do this in ML. This is pretty
%       thoroughly commented, so if you're trying to learn bitmap 
%       structure,maybe this is a good place to look. 
%       - I have an associated file on MATLAB Central's File Exchange
%       called BMP2MAT which reads a bitmap and stores is into a matrix
%       capable of being displayed using image and imagsc.
%
%   Bugs/Issues/Current Version/Future Versions:
%       -I'm considering making the input arg order mat,filename,colormap.
%       That why I can more easily determine if a filename's been passed
%       and launch a uiputfile if it hasn't. If anyone has a preference or
%       suggestion, please let me know.
%       -Currently, this is aimed at 24 bits/pixel bitmaps. there's no
%       functionality for writing color tables, and I'm not sure what else
%       changes in other precisions. I'll look into as the next update, I
%       think.
%       -Hoping to add some Property/Value pair type varargin capabilities.
%       -Compression, prehaps, but not for a while.
%
%   Revision history:
%
%       V. 1.1:5.0 R4 - 2004-06-10 - Brian Mearns
%       =========================================
%       -Bug fix: specifying your own colormap actually works now, so does
%       taking the colormap from MATLAB's current colormap
%       -Bug fix: Didn't realize before, but the bytes of the image data
%       were all off by one, which was actually the problem with the
%       colormaps, but also lead to a wierd border on some images.
%
%       V. 1.1:1.0 R3 - 2004-05-05 - Brian Mearns
%       =========================================
%       -Fixed a bug: MxN matrices were throwing errors when the values in
%       a value in the matrix was <= 0, because it was trying to access the
%       assigned color map at that index. 
%
%       V. 1.1 R2 (formerly 1.05)- 2004-05-03 - Brian Mearns
%       ====================================================
%       -Implemented colormapping functionality for MxN matrices, so that
%       MxN may be saveed with color as determined by the current ML
%       colormap, or a colormap passed to Varargin at 1.
%
%       V. 1.0 R1 - 2004-04-29 - Brian Mearns
%       =====================================
%       -Created
%
%   Contact:
%       -Brian Mearns
%        bmearns@coe.neu.edu.No-Junk-Mail_GetRideOfMe
%        Please include something coherent and relevant in the subject line 
%        so I don't toss it out with the junk mail. And feel free to harass
%        me about making updates/fixes. Otherwise, I may never care enough
%        again.
%
%   version = I.F:b.q R
%       I: Infrastructure: Primarily reserved for major changes to the
%       infrstructure or other huge changes
%       F: Functionality: When new features are added
%       b: bug fixes: when a bug is fixed
%       q: quality engineering: slight alterations to improve quality;
%       e.g., increase speed (without major re-architecting), clean up gui,
%       etc. 
%       R: release number: the number of times this has been released up to
%       (and inclduing) this one (preceeded by an 'R');


if nargin==0
	a_name = 'sampleOut.bmp';
	a_mat = rand(100,100);
end

if nargin<3
	cmap = colormap;
else
	cmap = varargin{1};
end

s = size(a_mat);
width = s(2);
height = s(1);
bitsPerPixel = 24;
compression = 0;

bytesPerRow = width*bitsPerPixel/8;
%Number of bytes written to each row must be a mutliple of 4. Append 0's
% to end to make it fit
if mod(bytesPerRow,4) == 0
	toReachMOf4 = 0;
else
	toReachMOf4 = 4 - mod(bytesPerRow,4);
end

sizeOfFileInfo = 14;
sizeOfInfoHeader = 40;
sizeOfRGBQuadArray = 0;

offsetOfImage = sizeOfFileInfo + sizeOfInfoHeader + sizeOfRGBQuadArray;
sizeOfFile = offsetOfImage + bitsPerPixel/8*width*height;

fid = fopen(a_name,'w');

%writes each char of the string as a ubit8
% bytes 0x 0-1
fwrite(fid,'BM','ubit8');

%file size
% bytes 0x 2-5
fwrite(fid,sizeOfFile,'ubit32');

% set to zero
% bytes 0x 6-9
fwrite(fid,[0],'ubit32');

% offset of bitmap data
% bytes 0x A-D
fwrite(fid,offsetOfImage,'ubit32');

% size of info header in bytes
% b 0x E-11
fwrite(fid,sizeOfInfoHeader,'ubit32');

%width of bitmap in pixels
% b 0x 12-15
fwrite(fid,width,'ubit32');

%height of bitmap in pixels
% b 0x 16-19
fwrite(fid,height,'ubit32');

% set to one
% b 0x 1A-1B
fwrite(fid,1,'ubit16');

%bits per pixel
% b 0x 1C-1D
fwrite(fid,bitsPerPixel,'ubit16');

% file compression
% b 0x 1E-21
fwrite(fid,compression,'ubit32');

%size of image data or, if no compression, 0
% b 0x 22-25
fwrite(fid,0,'ubit32');

% bits/meter or zero (wide, high)
% b 0x 26-29,2A-2D
fwrite(fid,[0,0],'ubit32');

%	# of colors used or 0
% b 0x 2E-31
fwrite(fid,0,'uint32');

% numbers of colors that are important or zero if all are
% b 0x 31-34
fwrite(fid,0,'uint32');

%fill the space between now and the offset
%Somehwere along the lines, I lost count. Previosuly, this was set to 0x35,
%instead of 0x36, which was leading to every bite being offset by 1, which
%caused problems with colormapping, and lead to a broder around the image.
%At some point I'll find out where I lost count
%TODO find out where I lost count.
diff = offsetOfImage - hex2dec('36');
x = rand(1,diff);
fwrite(fid,x,'ubit8');

%put a_mat in the range from 0 to 1 (inclusive)
mx = max(max(a_mat(:)));
mn = min(min(a_mat(:)));
a_mat = a_mat - mn;
a_mat = a_mat./(mx-mn);

writeType = ['ubit',num2str(bitsPerPixel/3)];

if length(size(a_mat))==3	%image data is stored upside down in bmp
	for i=height:-1:1
		for j=1:width

			red = 255*a_mat(i,j,1);
			green = 255*a_mat(i,j,2);
			blue = 255*a_mat(i,j,3);

			fwrite(fid,[blue,green,red],writeType);

		end
			%write filler bites to reach multiple of 4
			extra = zeros(1,toReachMOf4);
			fwrite(fid,extra,'ubit8');
	end
else
	c = cmap;
	%a_mat ranges from 1 to length(colormap)
	a_mat = a_mat*(length(c)-1)+1;
	for i=height:-1:1	%image data is stored upside down in bmp
		for j=1:width

			idx = a_mat(i,j);
			red = 255*c(floor(idx),1);
			green = 255*c(floor(idx),2);
			blue = 255*c(floor(idx),3);			

			fwrite(fid,[blue,green,red],writeType);
		end
			%write filler bites to reach multiple of 4
			extra = zeros(1,toReachMOf4);
			fwrite(fid,extra,'ubit8');
	end
end





fclose(fid);