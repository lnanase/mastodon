import { FormattedMessage } from 'react-intl';

// import { GIF } from './gif';
import illustration from '@/images/yukiho.png';

export const RegenerationIndicator: React.FC = () => (
  <div className='regeneration-indicator'>
    <div className='regeneration-indicator__figure'>
      <img src={illustration} alt='regeneration now' />
    </div>
    {/* <GIF
      src='/loading.gif'
      staticSrc='/loading.png'
      className='regeneration-indicator__figure'
    /> */}

    <div className='regeneration-indicator__label'>
      <strong>
        <FormattedMessage
          id='regeneration_indicator.preparing_your_home_feed'
          defaultMessage='Preparing your home feed…'
        />
      </strong>
      <FormattedMessage
        id='regeneration_indicator.please_stand_by'
        defaultMessage='Please stand by.'
      />
    </div>
  </div>
);
