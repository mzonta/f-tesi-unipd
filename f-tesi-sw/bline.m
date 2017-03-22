## Copyright (C) 2015 Massimiliano Zonta
## 
## This program is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
## (at your option) any later version.
## 
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
## 
## You should have received a copy of the GNU General Public License
## along with this program.  If not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*- 
## @deftypefn {Function File} {@var{retval} =} bline (@var{input1}, @var{input2})
##
## @seealso{}
## @end deftypefn

## Author: Massimiliano Zonta <mzonta@ubuntu>
## Created: 2015-05-29

function [y_1, y, y1, y2] = bline (s, x_2, x_1, x, x1, x2)

  l=length(s)
  
  for i=1:l-1
    sx=s(i);
    y_1(i)=(1-sx)*x_2+sx*x_1
    y(i)=(1-sx)*x_1+sx*x
    y1(i)=(1-sx)*x+sx*x1
    y2(i)=(1-sx)*x1+sx*x2
  end
  
endfunction
