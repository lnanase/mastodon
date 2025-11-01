import PropTypes from 'prop-types';
import React from 'react';


import ImmutablePropTypes from 'react-immutable-proptypes';

import AlternateEmailIcon from '@/material-icons/400-24px/alternate_email.svg?react';
import LockIcon from '@/material-icons/400-24px/lock.svg?react';
import PublicIcon from '@/material-icons/400-24px/public.svg?react';
import QuietTimeIcon from '@/material-icons/400-24px/quiet_time.svg?react';

import { autoPlayGif } from '../initial_state';

import { Icon } from './icon';


const icons = {
  public: PublicIcon,
  unlisted: QuietTimeIcon,
  private: LockIcon,
  direct: AlternateEmailIcon,
};

export default class AvatarOverlayIcon extends React.PureComponent {

  static propTypes = {
    account: ImmutablePropTypes.map.isRequired,
    visibility: PropTypes.string.isRequired,
    animate: PropTypes.bool,
  };

  static defaultProps = {
    animate: autoPlayGif,
  };

  render() {
    const { account, visibility, animate } = this.props;
    const icon = icons[visibility];

    const baseStyle = {
      backgroundImage: `url(${account.get(animate ? 'avatar' : 'avatar_static')})`,
    };

    return (
      <div className='account__avatar-overlay'>
        <div className='account__avatar-overlay-icon-base' style={baseStyle} />
        <Icon id={visibility} icon={icon} className='account__avatar-overlay-icon-overlay' />
      </div>
    );
  }

}
