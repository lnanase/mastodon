import { Record } from 'immutable';

import { render } from '@/testing/rendering';

import AvatarOverlayIcon from '../avatar_overlay_icon';

const AccountRecord = Record({
  id: '1',
  acct: 'alice',
  avatar: '/animated/alice.gif',
  avatar_static: '/static/alice.jpg',
});

describe('<AvatarOverlayIcon />', () => {
  const account = new AccountRecord();

  it('directのときAlternateEmailアイコンと静止画avatarが表示される', () => {
    const { container } = render(<AvatarOverlayIcon account={account} visibility='direct' animate={false} />);
    expect(container.firstChild).toMatchSnapshot();
    expect(container.innerHTML).toContain('/static/alice.jpg');
  });

  it('privateのときLockアイコンが表示される', () => {
    const { container } = render(<AvatarOverlayIcon account={account} visibility='private' animate={false} />);
    expect(container.firstChild).toMatchSnapshot();
  });

  it('unlistedのときQuietTimeアイコンが表示される', () => {
    const { container } = render(<AvatarOverlayIcon account={account} visibility='unlisted' animate={false} />);
    expect(container.firstChild).toMatchSnapshot();
  });

  it('animate=trueでアニメーションavatarが表示される', () => {
    const { container } = render(<AvatarOverlayIcon account={account} visibility='direct' animate />);
    expect(container.firstChild).toMatchSnapshot();
    expect(container.innerHTML).toContain('/animated/alice.gif');
  });
});
