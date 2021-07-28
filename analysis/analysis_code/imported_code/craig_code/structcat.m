function a = structcat(a, b, dim, omitfields)
% d = structcat(a, b, dim, omitfields)
%
% Concatenates all matching fields of b onto structure a along dimension
%   dim.  If dim is not specified, they will be horizontally concatenated
%   (dim = 2).
%
% Fields can be selectively omitted from the concatenation with omitfields.
%
% -EK June 6, 2008

if nargin < 3
    dim = 2;
end
if nargin < 4
    omitfields = {};
end

%ccEdit since a can be empty, define fnames with b
fnames = fieldnames(b);


%Loop for each field name of b, and add b's values to a, if a does not have
%that field, add it, then concatinate
for i = 1:length( fnames )
    fn = fnames{i};
    if ~isfield(a,fn) && isempty( strmatch(fn, omitfields) )
        a.(fn) = [];
    end
    if isempty( strmatch(fn, omitfields) )
        a.(fn) = cat(dim, a.(fn), b.(fn));
    end
end