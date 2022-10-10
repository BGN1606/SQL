DECLARE
	 @dkey VARCHAR(512) = 'KiHeSEuXaDyOs4rjoBWWn1PkCkZRzI71b5pEtV7oNbelBCUGiqGZ/XB6YlvozWADJaI5xj7QD1PvRVr9CR5FNbenKKh0hO1TFZkmkYsG8xazNySKNwWDkxz5Vpdx4ff/gNtAcWkv7oA2kvbLTbuMFpo7h2fzphV8UK3ikqrpRBHzqEjXY+3fGK8q6yj5owaxsXGa+82nNrenpDXL63sq4WZROH18+IWaL8ZEgYFeWvTAkxp0ha3sWM/ZeRiUNEFjcOUIBgeF+aYSRzZ7w4fe1PJ9yIJ2ky+2Oz8eN5LJscOGB3/FWUaWA7uh/yqnZ9VVwXOTMKT09FTHARA+eMqq7w=='
	,@rkey VARCHAR(512) = '86aYZ5IhOUqarGLw9SOO5aQCwfvR0k2RtKpnGXkeODmEAVvxVRGqeqlgem96U65w9wovSrqwgdTn5aIEe9Ag/ocapn6yhRDdQuTKSAh6g8977OFpsa0ijxs1NZNEijjB/1Y/xXQJKF9qZFUYv3AwEOf/VHv4nFQiwj3coDwImKE2h5pA8+RRhlSCSqnVACq14b2KeBhXxLdkDYZ02/HBiccxsVRXaXkDHxbtENDhodtKcHzJMJPKt9+LEQPecPS1g0l556weuasl+kSiBwr9xF2U0mDWaJm65yCtfyfyKKe/W4juIjPfA9I5Fy8kBefIC2T7W1qQxPaJAYoWLvz4wg=='
	,@startdate	DATE = '20190101'
	,@cutdate	DATE = '20200801'
	,@enddate	DATE = '20201231'


EXEC [Reporting].[dbo].[CustomerBrand_review] @rkey, @dkey, @startdate, @cutdate, @enddate