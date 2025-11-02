import PropTypes from 'prop-types';

const Foldable = ({ fullHeight, minHeight, isVisible, children }) => {
  const height = isVisible ? fullHeight : minHeight;
  
  return (
    <div 
      style={{ 
        height: `${height}px`, 
        maxHeight: '20vh',
        transition: 'height 300ms ease-in-out',
        overflow: 'hidden'
      }} 
      className='scrollable optionally-scrollable'
    >
      {children}
    </div>
  );
};

Foldable.propTypes = {
  fullHeight: PropTypes.number.isRequired,
  minHeight: PropTypes.number.isRequired,
  isVisible: PropTypes.bool.isRequired,
  children: PropTypes.node.isRequired,
};

export default Foldable;
