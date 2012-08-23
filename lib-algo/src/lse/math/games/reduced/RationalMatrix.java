package lse.math.games.reduced;

import java.io.StringWriter;
import java.util.Arrays;
import java.util.HashSet;
import java.util.LinkedList;
import java.util.List;
import java.util.Set;

import lse.math.games.Rational;
import lse.math.games.io.ColumnTextWriter;

public class RationalMatrix 
{
	private Rational[][] _matrix;
	private int _row;
	private int _column;
	private int _basisSize;
	private List<Integer> _basisHead;
	
	public RationalMatrix(int m, int n) {
		this(m,n,false);
	}
	
	public RationalMatrix(int m, int n, boolean unit) {
		_row = m;
		_column = n;
		_matrix = new Rational[_row][_column];
		for (int i = 0; i < _row; i++) {
			for (int j = 0; j < _column; j++) {
				if (unit == true && i == j) {
					_matrix[i][j] = Rational.ONE;
				} else {
					_matrix[i][j] = Rational.ZERO;
				}
			}
		}
	}
	
	public RationalMatrix(RationalMatrix other) {
		_row = other._row;
		_column = other._column;
		
		_matrix = new Rational[_row][_column];
		for (int i = 0; i < _row; i++) {
			for (int j = 0; j < _column; j++) {
				_matrix[i][j] = new Rational(other._matrix[i][j]);
			}
		}
	}

	public RationalMatrix(Integer[][] other) {
		_row = other.length;
		if (_row == 0) {
			return;
		}
		
		_column = other[0].length;
		
		_matrix = new Rational[_row][_column];
		for (int i = 0; i < _row; i++) {
			for (int j = 0; j < _column; j++) {
				_matrix[i][j] = Rational.valueOf(other[i][j]);
			}
		}
	}
	
	public RationalMatrix(Rational[][] other) {
		_row = other.length;
		if (_row == 0) {
			return;
		}
		
		_column = other[0].length;
		
		_matrix = new Rational[_row][_column];
		for (int i = 0; i < _row; i++) {
			for (int j = 0; j < _column; j++) {
				_matrix[i][j] = new Rational(other[i][j]);
			}
		}
	}
	
	public RationalMatrix copy() {
		RationalMatrix result = new RationalMatrix(_row, _column);
		for (int i = 0; i < _row; i++) {
			for (int j = 0; j < _column; j++) {
				result._matrix[i][j] = new Rational(_matrix[i][j]);
			}
		}
		return result;
	}
	
	public RationalMatrix getColumn(int idx) {
		RationalMatrix vector = new RationalMatrix(_row, 1);
		for (int i = 0; i < _row; i++) {
			vector.setElement(i, 0, _matrix[i][idx]);
		}
		return vector;
	}

	public void setColumn(int idx, RationalMatrix vector) {
		for (int i = 0; i < _row; i++) {
			_matrix[i][idx] = vector._matrix[i][0];
		}
	}
	
	public RationalMatrix appendBelow(RationalMatrix other) {
		if (_column != other._column) {
			return null;
		}
		
		RationalMatrix result = new RationalMatrix(_row + other._row, _column);
		for (int i = 0; i < _row; i++) {
			for (int j = 0; j < _column; j++) {
				result._matrix[i][j] = new Rational(_matrix[i][j]);
			}
		}
		for (int i = 0; i < other._row; i++) {
			for (int j = 0; j < other._column; j++) {
				result._matrix[_row + i][j] = new Rational(other._matrix[i][j]);
			}
		}
		return result;
	}
	
	public RationalMatrix appendAfter(RationalMatrix other) {
		if (_row != other._row) {
			return null;
		}
		
		RationalMatrix result = new RationalMatrix(_row, _column + other._column);
		for (int i = 0; i < _row; i++) {
			for (int j = 0; j < _column; j++) {
				result._matrix[i][j] = new Rational(_matrix[i][j]);
			}
			for (int j = 0; j < other._column; j++) {
				result._matrix[i][_column + j] = new Rational(other._matrix[i][j]);
			}
		}
		return result;
	}
	
	public RationalMatrix multiply(Rational alpha) {
		
		RationalMatrix result = new RationalMatrix(_row, _column);
		for (int i = 0; i < _row; i++) {
			for (int j = 0; j < _column; j++) {
				result._matrix[i][j] = _matrix[i][j].multiply(alpha);
			}
		}		
		return result;
	}
	
	public RationalMatrix multiply(RationalMatrix other) {

		if (_column != other._row) {
			return null;
		}
		
		RationalMatrix result = new RationalMatrix(_row, other._column);
		for (int i = 0; i < _row; i++) {
			for (int j = 0; j < other._column; j++) {
				
				result._matrix[i][j] = Rational.ZERO;
				
				for (int k = 0; k < _column; k++) {
					result._matrix[i][j] = result._matrix[i][j].add(_matrix[i][k].multiply(other._matrix[k][j]));
				}
			}
		}		
		return result;
	}

	public RationalMatrix add(RationalMatrix other) {
		if (_row != other._row || _column != other._column) {
			return null;
		}
		
		RationalMatrix result = new RationalMatrix(_row, _column);
		for (int i = 0; i < _row; i++) {
			for (int j = 0; j < _column; j++) {
				result._matrix[i][j] = _matrix[i][j].add(other._matrix[i][j]);
			}
		}		
		return result;
	}

	public RationalMatrix transpose() {
		RationalMatrix result = new RationalMatrix(_column, _row);
		for (int i = 0; i < _row; i++) {
			for (int j = 0; j < _column; j++) {
				result._matrix[j][i] = new Rational(_matrix[i][j]);
			}
		}
		return result;
	}

	public void setElement(int i, int j, Rational r) {
		_matrix[i][j] = new Rational(r);
	}
	
	public Rational getElement(int i, int j) {
		return _matrix[i][j];
	}

	public RationalMatrix getSubmatrix(int i0, int j0, int i1, int j1) {
		RationalMatrix result = new RationalMatrix(i1-i0, j1-j0);
		for (int i = 0; i < i1-i0; i++) {
			for (int j = 0; j < j1-j0; j++) {
				result._matrix[i][j] = new Rational(_matrix[i0+i][j0+j]);
			}
		}
		return result;
	}
	
	
	public int getRowSize() {
		return _row;
	}

	public int getColumnSize() {
		return _column;
	}
	
	public RationalMatrix inverse() {
		RationalMatrix result = this.copy();
		result.invert();
		return result;
	}
	
	public void invert() {
		if (_row != _column) {
			return;
		}
		
		RationalMatrix temp = new RationalMatrix(_row, _row * 2);
		for (int i = 0; i < _row; i++) {
			for (int j = 0; j < _column; j++) {
				temp._matrix[i][j] = new Rational(_matrix[i][j]);
			}
			for (int j = 0; j < _column; j++) {
				if (i == j) {
					temp._matrix[i][_column + j] = Rational.ONE;
				} else {
					temp._matrix[i][_column + j] = Rational.ZERO;
				}
			}
		}
		
		temp.gaussJordanElimination();
		
		for (int i = 0; i < _row; i++) {
			for (int j = 0; j < _column; j++) {
				_matrix[i][j] = temp._matrix[i][_column + j];
			}
		}
	}
	
	public void makeBasisForm() {
		gaussJordanElimination();
	}
	
	public List<Integer> getBasisHead() {
		return _basisHead;
	}
	
	public RationalMatrix getBasis() {
		RationalMatrix B = new RationalMatrix(_basisSize, _basisSize);
		for (int i = 0; i < _basisSize; i++) {
			B.setColumn(i, this.getColumn(_basisHead.get(i)));
		}
		return B;
	}
	
	public RationalMatrix getNonBasis() {
		RationalMatrix R = new RationalMatrix(_basisSize, _column - _basisSize);
		
		Set<Integer> basisIdx = new HashSet<Integer>();
		for (int i = 0; i < _basisSize; i++) {
			basisIdx.add(_basisHead.get(i));
		}
		
		for (int i = 0, j = 0; i < _column; i++) {
			if (basisIdx.contains(i) == false) {
				R.setColumn(j, this.getColumn(i));
				j++;
			}
		}
		
		return R;		
	}

	private void gaussJordanElimination() {
		
//		logi("Making basis... from \n%s", this.toString());
		
		_basisSize = _column < _row ? _column : _row;
		_basisHead = Arrays.asList(new Integer[_basisSize]);
		int [] columnState = new int [ _column ];
		
		int size = 0;
		for (int k = 0; k < _column && size < _basisSize; k++ ) {
			
			/* Find pivot column */
			
			/* If the pivot element is zero,
			 *  then skip this column */
			if (_matrix[size][k].isZero()) {
				continue;
			}
						
			for (int i = 0; i < _row; i++) {
				if (i != size) {
					Rational sum = _matrix[i][k].divide(_matrix[size][k]);
					for (int j = 0; j < _column; j++) {
						if (columnState[j] == 0) {
							_matrix[i][j] = _matrix[i][j].subtract(sum.multiply(_matrix[size][j]));
						}
					}
				}
			}
			
			/* Choose current column into the basis */
			columnState[k] = 1;
			_basisHead.set(size, k);
			/* Increase the size of the basis */
			size++;
			
//			logi("\t%d. step: \n%s", k, this.toString());
		}
		
		/* Transform to ones in pivot positions */
		for (int k = 0; k < _row; k++ ) {
			int pivot = _basisHead.get(k);
			for (int j = 0; j < _column; j++ ) {
				if (j != pivot) {
					_matrix[k][j] = _matrix[k][j].divide(_matrix[k][pivot]);
				}
			}
			_matrix[k][pivot] = Rational.ONE;
		}
		
//		logi("Making basis... new form \n%s", this.toString());
//		logi("Making basis... basis head %s", Arrays.toString(_basisHead));
	}

	@Override
	public 	String toString() {
		ColumnTextWriter colpp = new ColumnTextWriter();
		
		for (int i = 0; i < _row; i++) {
			for (int j = 0; j < _column; j++) {
				colpp.writeCol(_matrix[i][j].toString());
			}
			/* Make new line */
			colpp.endRow();
		}
		
		StringWriter output = new StringWriter();
		output.write(colpp.toString());
		return output.toString();
	}

	@Override
	public int hashCode() {
		final int prime = 31;
		int result = 1;
		result = prime * result
				+ ((_basisHead == null) ? 0 : _basisHead.hashCode());
		result = prime * result + _basisSize;
		result = prime * result + _column;
		result = prime * result + Arrays.hashCode(_matrix);
		result = prime * result + _row;
		return result;
	}

	@Override
	public boolean equals(Object obj) {
		if (this == obj)
			return true;
		if (obj == null)
			return false;
		if (getClass() != obj.getClass())
			return false;
		RationalMatrix other = (RationalMatrix) obj;
		if (_basisHead == null) {
			if (other._basisHead != null)
				return false;
		} else if (!_basisHead.equals(other._basisHead))
			return false;
		if (_basisSize != other._basisSize)
			return false;
		if (_column != other._column)
			return false;
		if (!Arrays.deepEquals(_matrix, other._matrix))
			return false;
		if (_row != other._row)
			return false;
		return true;
	}

	public 	String rowtoString(int i) {
		ColumnTextWriter colpp = new ColumnTextWriter();
		
		for (int j = 0; j < _column; j++) {
			colpp.writeCol(_matrix[i][j].toString());
		}
		
		StringWriter output = new StringWriter();
		output.write(colpp.toString());
		return output.toString();
	}

}
