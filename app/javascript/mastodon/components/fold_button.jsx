import classNames from 'classnames';
import { PureComponent } from 'react';

export default class FoldButton extends PureComponent {

  handleClick = (e) => {
    e.preventDefault();
    if (!this.props.disabled && this.props.onClick) {
      this.props.onClick(e);
    }
  };

  render () {
    const style = {
      fontSize: `${this.props.size}px`,
      width: `${this.props.size * 1.28571429}px`,
      height: `${this.props.size * 1.28571429}px`,
      lineHeight: `${this.props.size}px`,
      ...this.props.style,
      ...(this.props.active ? this.props.activeStyle : {}),
    };

    const {
      active,
      animate,
      className,
      disabled,
      expanded,
      icon,
      inverted,
      overlay,
      pressed,
      tabIndex,
      title,
    } = this.props;

    const classes = classNames(className, 'icon-button', {
      active,
      disabled,
      inverted,
      overlayed: overlay,
    });

    const iconStyle = animate ? {
      transform: `rotate(${active ? 0 : 180}deg)`,
      transition: 'transform 300ms ease-in-out'
    } : {
      transform: `rotate(${active ? 180 : 0}deg)`
    };

    return (
      <button
        aria-label={title}
        aria-pressed={pressed}
        aria-expanded={expanded}
        title={title}
        className={classes}
        onClick={this.handleClick}
        style={style}
        tabIndex={tabIndex}
      >
        <i style={iconStyle} className={`fa fa-fw fa-${icon}`} aria-hidden='true' />
      </button>
    );
  }

}
